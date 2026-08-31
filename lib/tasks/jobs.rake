require 'json'
require 'date'

namespace :jobs do
  desc "Changing jobs DB"

  task update: :environment do
    file_data = File.read('db/scrapes/2026-08-31cfn.json')
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
        salary: data["salary"],
        source_url: data["job_url"]
      )
    end
  end
end
