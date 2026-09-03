require 'net/http'
require 'json'
require 'uri'
require 'date'
require 'nokogiri'

class ScrapeJapandevJob < ApplicationJob
  queue_as :default
  MEILI_URL = "https://meili.japan-dev.com/multi-search"
  API_URL = "https://api.japan-dev.com/api/v1/companies/%{company_id}/jobs"

  MEILI_HEADERS = {
    'accept' => '*/*',
    'accept-language' => 'en-US,en;q=0.9',
    'authorization' => "Bearer #{ENV.fetch('JAPANDEV_MEILI_KEY')}",
    'content-type' => 'application/json',
    'origin' => 'https://japan-dev.com',
    'referer' => 'https://japan-dev.com/',
    'user-agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36'
  }.freeze

  API_HEADERS = {
    'accept' => '*/*',
    'accept-language' => 'en-US,en;q=0.9',
    'referer' => 'https://japan-dev.com/',
    'user-agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36'
  }.freeze

  LIMIT = 21

  BLOCK_TAGS = %w[
    p div br li ul ol tr section article header
    footer h1 h2 h3 h4 h5 h6 table blockquote pre
  ].freeze

  def perform(*args)
    def html_to_text(html)
      return html if html.nil? || html.empty?

      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      parts = []

      doc.traverse do |node|
        if node.text?
          parts << node.text
        elsif node.element? && BLOCK_TAGS.include?(node.name.downcase)
          parts << "\n"
        end
      end

      text = parts.join
      text = text.gsub(/[ \t]+/, ' ')
      text = text.gsub(/ *\n */, "\n")
      text = text.gsub(/\n{3,}/, "\n\n")
      text.strip
    end

    # --- HTTP helpers ---
    def fetch_json_post(url, headers, payload)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      request = Net::HTTP::Post.new(uri.request_uri)
      headers.each { |k, v| request[k] = v }
      request.body = payload.to_json

      response = http.request(request)
      raise "HTTP #{response.code}: #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def fetch_json_get(url, headers)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')

      request = Net::HTTP::Get.new(uri.request_uri)
      headers.each { |k, v| request[k] = v }

      response = http.request(request)
      raise "HTTP #{response.code}: #{response.message}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def fetch_meili_page(offset)
      payload = {
        queries: [
          {
            indexUid: "Job_production",
            q: "",
            facets: [
              "candidate_location", "company_is_startup", "company_name",
              "english_level_enum", "japanese_level_enum", "job_type_names",
              "location", "remote_level", "salary_tags", "seniority_level",
              "skill_names"
            ],
            filter: [
              "",
              [
                '"seniority_level"="seniority_level_junior"',
                '"seniority_level"="seniority_level_new_grad"'
              ]
            ],
            limit: LIMIT,
            offset: offset
          }
        ]
      }

      data = fetch_json_post(MEILI_URL, MEILI_HEADERS, payload)
      data['results'][0]
    end

    def scrape_company_jobs(company_id, cache)
      return cache[company_id] if cache.key?(company_id)

      url = format(API_URL, company_id: company_id)
      jsondata = fetch_json_get(url, API_HEADERS)

      jobs_by_id = {}
      jsondata['data'].each do |entry|
        attrs = entry['attributes']
        jobs_by_id[attrs['id'].to_s] = attrs
      end

      cache[company_id] = jobs_by_id
      sleep 0.3
      jobs_by_id
    end

    def format_yen(amount)
      amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    end

    # --- Main scrape loop ---
    jobs = []
    company_jobs_cache = {} # company_id -> {job_id => attributes}
    offset = 0

    loop do
      page_data = fetch_meili_page(offset)
      hits = page_data['hits']

      break if hits.empty?

      hits.each do |job|
        company_id = job['company_id']
        job_id = job['id'].to_s

        full_jobs = scrape_company_jobs(company_id, company_jobs_cache)
        full_job = full_jobs.fetch(job_id, {})

        salary_min = job['salary_min']
        salary_max = job['salary_max']
        salary = salary_min && salary_max ? "¥#{format_yen(salary_min)} - ¥#{format_yen(salary_max)}" : nil

        job_url = "https://japan-dev.com/jobs/#{job['company']['slug']}/#{job['slug']}"

        jobs << {
          company_name: job['company_name'],
          company_info: full_job.dig('company', 'description'),
          logo_link: job['company']['logo_url'] ? "https://japan-dev.com/cdn/company_logos/#{job['company']['logo_url']}" : nil,
          job_name: job['title'],
          deadline: nil,
          jd: html_to_text(full_job['raw_content']),
          job_url: job_url,
          source_url: job_url,
          internship: job['is_internship'],
          location: job['location'],
          salary: salary,
          job_id: job['id']
        }
      end

      offset += LIMIT
      break if offset >= (page_data['estimatedTotalHits'] || 0)

      sleep 0.3
    end

    jobs.each do |data|
      company = Company.find_or_create_by(name: data[:company_name])
      company.update(
        description: data[:company_info]
      )
      logo = URI.parse(data[:logo_link]).open
      company.logo.attach(io: logo, filename: "logo.png", content_type: "image/png") unless company.logo.attached?

      job_opening = JobOpening.find_or_create_by(title: data[:job_name])
      job_opening.update(
        company: company,
        deadline: data[:deadline].nil? ? "N/A" : Date.parse(data[:deadline]),
        content: data[:jd],
        job_url: data[:job_url],
        location: data[:location],
        salary: data[:salary].nil? ? "N/A" : data[:salary],
        source_url: data[:job_url],
        employment_type: data[:internship] ? "Internship" : "Fulltime",
        source: "Japandev"
      )
      job_opening.closed = job_opening.deadline.is_a?(Date) && Date.current > job_opening.deadline
      job_opening.save
    end
  end
end
