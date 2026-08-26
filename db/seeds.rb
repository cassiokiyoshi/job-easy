puts "Starting seed..."
puts "Cleaning database..."

Task.destroy_all
Resume.destroy_all
JobApplication.destroy_all
JobOpening.destroy_all
Company.destroy_all
User.destroy_all

puts "Creating user..."

user = User.create!(
  email: "test@mail.com",
  password: "secret"
)

companies_data = [
  {
    name: "Le Wagon",
    description: "A global education company helping people develop practical technology skills and launch careers in tech."
  },
  {
    name: "Northstar Labs",
    description: "A product studio building accessible digital tools for education, productivity, and remote collaboration."
  },
  {
    name: "Orbit Analytics",
    description: "A data analytics company helping growing businesses understand customer behavior and improve decision-making."
  },
  {
    name: "Lumen Technologies",
    description: "A software company creating modern cloud platforms and tools for distributed engineering teams."
  },
  {
    name: "Atlas Systems",
    description: "A technology consultancy delivering web applications and digital transformation projects for global clients."
  },
  {
    name: "Pioneer Health",
    description: "A healthcare technology company building secure platforms that improve access to patient services."
  },
  {
    name: "Greenline Energy",
    description: "A renewable energy company using software and data to improve the efficiency of sustainable infrastructure."
  },
  {
    name: "Summit Finance",
    description: "A financial technology company providing simple digital tools for budgeting, payments, and financial planning."
  },
  {
    name: "Harbor Commerce",
    description: "An e-commerce platform helping independent retailers manage inventory, orders, and customer relationships."
  },
  {
    name: "PixelCraft Studio",
    description: "A design and development agency creating accessible, user-focused digital products for startups and businesses."
  }
]

job_titles = [
  "Junior Ruby on Rails Developer",
  "Frontend Developer",
  "Backend Developer",
  "Full Stack Developer",
  "Software Engineer",
  "Junior Product Designer",
  "UX Designer",
  "UI Designer",
  "Product Analyst",
  "Data Analyst",
  "Data Analyst Intern",
  "QA Engineer",
  "DevOps Engineer",
  "Customer Success Associate",
  "Technical Support Engineer",
  "Associate Product Manager",
  "Mobile Developer",
  "Cloud Engineer",
  "Junior Data Engineer",
  "Business Analyst"
]

job_descriptions = [
  "Join a collaborative engineering team and help build reliable product features from planning through deployment.",
  "Create responsive and accessible interfaces while working closely with designers and backend engineers.",
  "Develop and maintain APIs, improve application performance, and contribute to technical planning.",
  "Work across the product stack to deliver features that solve real customer problems.",
  "Build dependable software, review code, and participate in decisions about architecture and product development.",
  "Support the design team with user research, prototyping, usability testing, and interface design.",
  "Turn research findings into simple and intuitive experiences for web and mobile products.",
  "Create polished interface components and help maintain a consistent design system.",
  "Analyze product behavior, prepare reports, and help teams make informed product decisions.",
  "Work with real datasets, build dashboards, and communicate useful insights to stakeholders."
]

puts "Creating companies..."

companies = companies_data.map do |attributes|
  Company.create!(attributes)
end

puts "Creating job openings..."

job_openings = []

companies.each_with_index do |company, company_index|
  5.times do |opening_index|
    global_index = (company_index * 5) + opening_index
    closed = (global_index % 9).zero?

    job_openings << JobOpening.create!(
      company: company,
      title: job_titles[global_index % job_titles.length],
      content: job_descriptions[global_index % job_descriptions.length],
      closed: closed,
      deadline: closed ? (global_index + 1).days.ago : (global_index + 14).days.from_now,
      job_url: "https://example.com/jobs/#{global_index + 1}",
      source_url: "https://example.com/companies/#{company.name.parameterize}/careers"
    )
  end
end

puts "Creating job applications..."

statuses = %w[
  Saved
  Applied
  Interviewed
  Offered
  Accepted
  Rejected
]

20.times do |index|
  JobApplication.create!(
    user: user,
    job_opening: job_openings[index],
    status: statuses[index % statuses.length]
  )
end

puts "Seed completed!"
puts "Created #{User.count} user"
puts "Created #{Company.count} companies"
puts "Created #{JobOpening.count} job openings"
puts "Created #{JobApplication.count} job applications"

JobApplication.group(:status).count.each do |status, count|
  puts "#{status}: #{count}"
end
