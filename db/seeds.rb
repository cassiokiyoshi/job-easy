# User 1
# Company 1
# Job Opening 2
puts "Starting seed"

puts "Cleaning db...."
Resume.destroy_all
User.destroy_all
Company.destroy_all
JobApplication.destroy_all

puts "Creating seeds..."
user = User.create(
  email: "test@mail.com",
  password: "secret"
)

company = Company.create(
  name: "Le Wagon",
  description: "Le Wagon is a global education company that helps people build skills and launch careers in tech. Through immersive, hands-on programs, it supports learners at various stages of their journey — from complete beginners to working professionals — in developing practical, in-demand abilities. With a presence across multiple countries, Le Wagon brings together a community of instructors, alumni, and industry partners focused on real-world learning outcomes."
)

JobOpening.create!(
  title: "Junior Ruby on Rails Developer",
  closed: false,
  company: company,
  content: "We're looking for a junior Rails developer to join our engineering team. " \
           "You'll work on our core product, collaborate with a small cross-functional team, " \
           "and ship features end-to-end. Ruby/Rails experience from a bootcamp or personal " \
           "projects is welcome — we care more about problem-solving ability and eagerness to learn.",
  deadline: 3.weeks.from_now,
  job_url: "https://www.lewagon.com/careers/junior-rails-developer",
  source_url: "https://www.lewagon.com/careers"
)

job_frontend = JobOpening.create!(
  title: "Frontend Developer (React)",
  closed: false,
  company: company,
  content: "Join our frontend team building responsive, accessible interfaces with React. " \
           "You'll work closely with designers and backend engineers to bring new features " \
           "to life. Experience with modern JS tooling, component-based architecture, and " \
           "a good eye for UX are a plus.",
  deadline: 1.month.from_now,
  job_url: "https://www.lewagon.com/careers/frontend-developer-react",
  source_url: "https://www.lewagon.com/careers"
)

JobOpening.create!(
  title: "Data Analyst Intern",
  closed: true,
  company: company,
  content: "This internship gave students hands-on experience working with real datasets, " \
           "building dashboards, and supporting the data team's reporting needs. " \
           "The position has since been filled and applications are now closed.",
  deadline: 2.weeks.ago,
  job_url: "https://www.lewagon.com/careers/data-analyst-intern",
  source_url: "https://www.lewagon.com/careers"
)

JobApplication.create!(
  job_opening: job_frontend,
  user: user
)

puts "Created #{JobOpening.count} openings with #{Company.count} company"
