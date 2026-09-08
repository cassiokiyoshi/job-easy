namespace :jobs do
  desc "Run all job scrapers"
  task scrape: :environment do
    ScrapeWantedlyJob.perform_now
    ScrapeJapandevJob.perform_now
    ScrapeCfnJob.perform_now
  end
end
