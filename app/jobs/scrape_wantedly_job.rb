class ScrapeWantedlyJob < ApplicationJob
  queue_as :default

  require 'open-uri'
  require "nokogiri"
  require "json"

  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36".freeze

  def perform
    jobs = []

    def scrape_project(link)
      nokogiri = Nokogiri::HTML.parse(fetch_html(link))

      # ProjectPlainDescription__PlainDescription-sc-ay222f-0 kGSTXn
      descriptions = nokogiri.search(".ProjectPlainDescription__PlainDescription-sc-ay222f-0").map do |node|
        node.text.strip
      end
      salary = nokogiri.search(".JobDescriptionSection__InformationItemDescription-sc-fy8aq1-6").map do |node|
        node.text.strip
      end.last

      {
        company_info: descriptions[3],
        jd: descriptions.last,
        salary: (salary =~ /円/ ? salary : nil)
      }
    end

    def fetch_html(url)
      sleep 1
      URI.parse(url).read("User-Agent" => USER_AGENT)
    end

    (1..5).each do |page|
      url = "https://www.wantedly.com/projects?new=true&page=#{page}&keywords=%E6%9C%AA%E7%B5%8C%E9%A8%93&keywords=Ruby&occupationTypes=jp__engineering&hiringTypes=mid_career&areas=tokyo&order=mixed"
      html = fetch_html(url)
      nokogiri = Nokogiri::HTML.parse(html)
      job_titles = nokogiri.search(".ProjectListJobPostItem__TitleTextMobile-sc-bjcnhh-6").map do |node|
        node.text.strip
      end
      company_names = nokogiri.search(".JobPostCompanyWithWorkingConnectedUser__CompanyNameText-sc-1nded7v-0").map do |node|
        node.text.strip
      end
      job_url = nokogiri.search('a[data-testid="project-list-item-link"]').map do |node|
        URI.join("https://www.wantedly.com", node["href"]).to_s
      end
      projects = job_url.map { |link| scrape_project(link) }
      logo_link = nokogiri.search(".JobPostCompanyWithWorkingConnectedUser__CompanyLogo-sc-1nded7v-2 .wui-avatar-layout img").map do
        |node| src = node["src"]
               if src =~ %r{(https://[^/]+)/(?:small_light\([^)]*\)/)*(assets/.+)}
                 "#{::Regexp.last_match(1)}/#{::Regexp.last_match(2)}"
               else
                 src
               end
      end
      job_titles.each_with_index do |title, i|
        jobs << { job_name: title, company_name: company_names[i], company_info: projects[i][:company_info],
                  logo_link: logo_link[i], jd: projects[i][:jd], job_url: job_url[i], source_url: job_url[i], internship: false, location: "Tokyo", salary: projects[i][:salary], tag: "Ruby" }
      end
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
        source: "Wantedly"
      )
      job_opening.closed = job_opening.deadline.is_a?(Date) && Date.current > job_opening.deadline
      job_opening.save
    end
  end
end
