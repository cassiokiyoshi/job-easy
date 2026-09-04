require 'json'
require 'date'

namespace :jobs do
  desc "Changing jobs DB"

  task update: :environment do
    file_data = File.read('db/scrapes/2026-09-04cfn.json')
    data_array = JSON.parse(file_data)
    data_array.each do |data|
      company = Company.find_or_create_by(name: data["company_name"])
      company.update(
        description: data["company_info"]
      )
      logo = URI.parse(data["logo_link"]).open
      company.logo.attach(io: logo, filename: "logo.png", content_type: "image/png") unless company.logo.attached?

      job_opening = JobOpening.find_or_create_by(title: data["job_name"])
      job_opening.update(
        company: company,
        deadline: Date.parse(data["deadline"]),
        content: data["jd"],
        job_url: data["job_url"],
        location: data["location"],
        salary: data["salary"].nil? ? "N/A" : data["salary"],
        source_url: data["job_url"],
        employment_type: data["internship"] ? "Internship" : "Fulltime",
        source: "CFN"
      )
      job_opening.closed = job_opening.deadline.is_a?(Date) && Date.current > job_opening.deadline
      job_opening.save
    end

    file_data = File.read('db/scrapes/2026-08-31wantedly.json')
    data_array = JSON.parse(file_data)
    data_array.each do |data|
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

    file_data = File.read('db/scrapes/2026-08-31japandev.json')
    data_array = JSON.parse(file_data)
    data_array.each do |data|
      company = Company.find_or_create_by(name: data["company_name"])
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
        source: "JapanDev"
      )
      job_opening.closed = job_opening.deadline.is_a?(Date) && Date.current > job_opening.deadline
      job_opening.save
    end
  end
end
