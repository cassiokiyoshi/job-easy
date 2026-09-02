class ScrapeWantedlyJob < ApplicationJob
  queue_as :default
  require 'open-uri'
  require "nokogiri"
  require "json"
  USER_AGENT = ENV.fetch("WANTEDLY_USER_AGENT")

  def perform
    # Fetch a URL as HTML with a browser-like User-Agent, with a small delay to
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
        company = Company.find_or_create_by(name: data["name"])
        company.update(
          description: data["company_info"]
        )

        logo = URI.parse(data["logo_link"]).open
        company.logo.attach(io: logo, filename: "logo.png", content_type: "image/png") unless company.logo.attached?

        job_opening = JobOpening.find_or_create_by(source_url: data["job_url"])
        job_opening.update(
          company: company,
          deadline: data["deadline"].nil? ? "N/A" : Date.parse(data["deadline"]),
          content: data["jd"],
          job_url: data["job_url"],
          location: data["location"],
          salary: data["salary"].nil? ? "N/A" : data["salary"],
          source_url: data["job_url"],
          employment_type: data["internship"] ? "Internship" : "Fulltime",
          title: data["job_name"],
          source: "Wantedly"
        )
        job_opening.closed = job_opening.deadline.is_a?(Date) && Date.current > job_opening.deadline
        job_opening.save
      end
    end
  end

  private

  # avoid hammering the server (which is what triggered the 403s).
  def fetch_html(url)
    sleep 1
    URI.parse(url).read("User-Agent" => USER_AGENT)
  end

  # Fetch a project detail page once and pull every field we need out of it,
  # so we don't download the same page three times.
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
end
