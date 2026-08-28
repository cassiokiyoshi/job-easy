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
  # Junior Ruby on Rails Developer
  "Join a collaborative engineering team and help build reliable product features from planning through deployment. You will work primarily in Ruby on Rails, writing controllers, models, and service objects backed by a PostgreSQL database. Day to day you will build server-rendered views with ERB and Hotwire, sprinkling in Stimulus and Turbo for interactivity. You will write tests with RSpec and Capybara, and keep the suite green before every merge. Our codebase uses Sidekiq and Redis for background jobs such as sending emails and syncing external data. You will pair regularly with senior engineers and take part in code review on GitHub pull requests. We use RuboCop and Brakeman in CI to keep the code consistent and secure. Deployments run through GitHub Actions to Heroku, and you will learn to read logs and metrics when something breaks. We expect you to ask questions early, break large tasks into small commits, and document what you build. This role is ideal for a bootcamp graduate who wants mentorship and a clear path to mid-level. You will finish your first quarter having shipped several user-facing features end to end.",
  # Frontend Developer
  "Create responsive and accessible interfaces while working closely with designers and backend engineers. You will build components in React with TypeScript, using hooks and modern functional patterns throughout. Styling is handled with Tailwind CSS and a shared component library documented in Storybook. You will consume REST and GraphQL APIs and manage client state with React Query and Zustand. Performance matters here, so you will profile renders, lazy-load routes, and keep Core Web Vitals healthy. You will write unit tests with Jest and React Testing Library, plus end-to-end coverage in Playwright. Our build pipeline uses Vite, ESLint, and Prettier, with checks enforced in GitHub Actions. You will collaborate in Figma with designers to turn mockups into pixel-accurate, keyboard-navigable screens. Accessibility is a requirement, not a nice-to-have, so you will test against WCAG guidelines and screen readers. You will help maintain our design tokens and contribute back improvements to the shared library. The ideal candidate cares about the details users feel but rarely notice.",
  # Backend Developer
  "Develop and maintain APIs, improve application performance, and contribute to technical planning. You will design and build services in Node.js and TypeScript, with some existing code in Python. Our data lives in PostgreSQL and Redis, and we use Prisma and raw SQL where it makes sense. You will build and version REST and gRPC endpoints consumed by web, mobile, and partner integrations. Asynchronous work runs through RabbitMQ and scheduled workers that you will help design and monitor. You will write integration tests, add observability with OpenTelemetry, and watch dashboards in Grafana and Prometheus. Services are containerized with Docker and deployed to Kubernetes through a CI pipeline. You will take part in on-call rotation after onboarding, with runbooks and support from the team. Database migrations, query optimization, and sensible indexing will be a regular part of your work. You will document architecture decisions and review designs from other engineers. We value code that is boring, predictable, and easy for the next person to change.",
  # Full Stack Developer
  "Work across the product stack to deliver features that solve real customer problems. On the frontend you will use React, TypeScript, and Tailwind CSS to build and refine user interfaces. On the backend you will work in Ruby on Rails and PostgreSQL, writing APIs and background jobs with Sidekiq. You will own features from database schema through API design to the final screen a user sees. Testing spans RSpec on the server and Jest with Playwright on the client, and you are expected to keep both healthy. We deploy with Docker and GitHub Actions, and you will help keep the pipeline fast and reliable. You will use Redis for caching and rate limiting, and integrate third-party services like Stripe and SendGrid. Feature flags let us ship small and often, and you will learn to roll changes out safely. You will join sprint planning and help estimate and scope work with the product manager. Clear written communication in pull requests and design docs is part of the job. This role suits someone who enjoys context switching and seeing the whole picture.",
  # Software Engineer
  "Build dependable software, review code, and participate in decisions about architecture and product development. You will work in a polyglot environment with Go and Python services and a React frontend. Data is stored across PostgreSQL, DynamoDB, and S3, with Kafka moving events between systems. You will design APIs, write clear technical proposals, and get feedback through our RFC process. Infrastructure is defined in Terraform and runs on AWS with EKS, and you will manage your own service from commit to production. Testing, tracing, and structured logging are expected for every change you ship. You will take part in a healthy on-call rotation supported by alerting in PagerDuty and dashboards in Datadog. Code review is a core activity here, and you will both give and receive thoughtful feedback daily. You will mentor newer engineers and help improve our tooling, CI speed, and documentation. We care about correctness, operability, and the long-term health of the codebase. The ideal engineer is pragmatic, curious, and comfortable with ambiguity.",
  # Junior Product Designer
  "Support the design team with user research, prototyping, usability testing, and interface design. You will work in Figma every day, building wireframes, high-fidelity mockups, and interactive prototypes. You will contribute to our design system, keeping components, tokens, and documentation consistent. Alongside senior designers you will plan and run usability sessions and synthesize what you learn. You will use tools like Maze and Dovetail to gather and organize research findings. Part of your week will involve reviewing analytics in Amplitude to understand how people actually use the product. You will present your work in design critiques and iterate quickly on the feedback you receive. Close collaboration with engineers means you will hand off specs, review builds, and catch visual regressions. Accessibility guides your decisions, so you will check color contrast, focus order, and readable typography. You will help write UX copy that is clear, friendly, and free of jargon. This role is a strong first step for someone moving from study or self-teaching into professional product design.",
  # UX Designer
  "Turn research findings into simple and intuitive experiences for web and mobile products. You will own end-to-end design work, from problem framing and journey mapping to detailed interaction design. Figma and FigJam are your main tools for wireframes, flows, and workshop facilitation. You will plan and run generative and evaluative research, including interviews, surveys, and usability tests. Findings will be organized in Dovetail and shared through concise reports and readouts. You will partner with product managers to define success metrics and track them in Amplitude or Mixpanel. Prototyping complex interactions, including motion and edge cases, will be a regular part of your work. You will contribute patterns back to the design system and help keep it coherent as it grows. Working with engineers, you will pair on implementation details and review the final experience. Accessibility and inclusive design are core expectations, tested against WCAG and assistive technology. You will advocate for the user while balancing business goals and technical constraints.",
  # UI Designer
  "Create polished interface components and help maintain a consistent design system. You will work in Figma, building and refining components, variants, and auto-layout structures. Your focus is visual craft: typography, spacing, color, iconography, and motion that feels intentional. You will define and maintain design tokens and keep them in sync with the engineering implementation. Working with developers, you will review builds in Storybook and flag pixel-level differences. You will design responsive layouts that hold up across breakpoints and dense data screens. Accessibility is part of visual design here, so you will check contrast ratios and state styling. You will produce marketing and product visuals, including illustrations and export-ready assets. Version control of the design library and clear changelogs will be part of your routine. You will contribute to our brand guidelines and help apply them consistently across surfaces. The ideal candidate has an exacting eye and enjoys systematizing visual decisions.",
  # Product Analyst
  "Analyze product behavior, prepare reports, and help teams make informed product decisions. You will write SQL against our data warehouse in BigQuery to answer questions about user behavior. Dashboards will be built and maintained in Looker and Amplitude for self-serve access across teams. You will define and document key metrics, funnels, and cohorts so everyone shares the same definitions. Working with product managers, you will design experiments and analyze A/B test results for significance. You will use Python with pandas for deeper analysis that goes beyond dashboard capabilities. Part of your job is translating messy business questions into clear, answerable analyses. You will present findings in concise readouts and recommend concrete next steps. Data quality matters, so you will help catch tracking gaps and work with engineers to fix them. You will contribute to our experimentation culture by teaching teams how to read results. The ideal analyst is skeptical, precise, and good at telling a story with numbers.",
  # Data Analyst
  "Work with real datasets, build dashboards, and communicate useful insights to stakeholders. You will write SQL daily against PostgreSQL and a Snowflake warehouse to pull and shape data. Reporting will live in Tableau and Metabase, and you will keep dashboards accurate and well documented. You will use Python with pandas and NumPy for cleaning, joining, and analyzing data that dashboards cannot handle. Stakeholders across marketing, finance, and operations will bring you questions to scope and answer. You will build repeatable analyses and, where useful, schedule them with dbt and Airflow. Clear visualization is a priority, so you will choose the right chart and label it well. You will help define metric definitions and maintain a shared data dictionary. Spotting anomalies and data quality issues early will be part of your value to the team. You will present results to non-technical audiences and adjust the depth to the room. The ideal candidate is curious, organized, and comfortable owning a question end to end.",
  # Data Analyst Intern
  "Work with real datasets, build dashboards, and communicate useful insights to stakeholders as part of a structured internship. You will learn to write SQL queries against our PostgreSQL database with guidance from the analytics team. You will use Python and pandas in Jupyter notebooks to clean and explore data. Simple dashboards in Metabase will be your first deliverables, built from real business questions. A mentor will pair with you weekly to review your work and explain how decisions get made. You will sit in on stakeholder meetings to see how analysis turns into action. Over the internship you will complete a capstone project and present it to the team. You will learn version control with Git and how to document an analysis so others can follow it. We will introduce you to experimentation, metric definitions, and the basics of data modeling. You will get honest feedback and a clear picture of what a full-time analyst role involves. This position is designed for students or recent graduates with coursework in statistics, computer science, or a related field.",
  # QA Engineer
  "Help ship high-quality releases by designing test strategy and building automated coverage. You will write end-to-end tests in Playwright and Cypress against our web application. API testing will use Postman and REST-assured style checks integrated into the pipeline. You will maintain a regression suite that runs on every pull request through GitHub Actions. Bug reports you file will be clear and reproducible, with logs, steps, and environment details in Jira. You will work with developers to add unit and integration tests closer to the code. Exploratory testing sessions will complement automation, especially for new features. You will help define acceptance criteria during refinement so quality is considered up front. Test data management, flaky test triage, and cross-browser coverage will be ongoing responsibilities. You will track quality metrics like escape rate and mean time to detection and report on trends. The ideal candidate is detail-oriented, systematic, and an advocate for the user's experience.",
  # DevOps Engineer
  "Own the infrastructure and pipelines that let engineers ship safely and often. You will manage cloud infrastructure on AWS, defined as code with Terraform and Terragrunt. Container workloads run on Kubernetes (EKS), and you will maintain Helm charts and deployment manifests. CI/CD pipelines are built in GitHub Actions and Argo CD, and you will keep them fast and reliable. Observability is a core focus, using Prometheus, Grafana, Loki, and OpenTelemetry across services. You will manage secrets with Vault and enforce least-privilege access with IAM policies. Incident response is part of the role, including on-call rotation, runbooks, and blameless postmortems. You will tune autoscaling, right-size resources, and keep the cloud bill under control. Security hardening, patching, and compliance checks will be automated wherever possible. You will partner with product teams to improve their deployment and rollback workflows. The ideal candidate treats infrastructure as a product with internal customers.",
  # Customer Success Associate
  "Help customers get value from the product and grow their trust in our company over time. You will own a portfolio of accounts, guiding them from onboarding through renewal. Salesforce and HubSpot will be your daily tools for tracking accounts, tasks, and communication. You will run onboarding calls, build success plans, and check in regularly on customer goals. Product usage data in Gainsight and Amplitude will help you spot risk and opportunity early. When customers hit technical issues, you will coordinate with support and engineering to resolve them. You will gather feedback and feed it to the product team with clear context and priority. Renewal and expansion conversations will be part of your quarterly targets. You will create help articles, short videos, and webinars to scale common guidance. Quarterly business reviews with key accounts will let you show impact and plan ahead. The ideal candidate is empathetic, organized, and genuinely motivated by customer outcomes.",
  # Technical Support Engineer
  "Be the technical problem-solver customers reach when something is not working. You will troubleshoot issues across our web application, REST API, and integrations. Reading logs in Datadog and querying PostgreSQL will be routine parts of diagnosis. You will reproduce bugs locally, write clear tickets in Jira, and escalate to engineering with detail. Support conversations happen in Zendesk, and you will keep response and resolution times healthy. You will write and maintain a knowledge base of solutions, FAQs, and troubleshooting guides. Common tasks include debugging webhooks, OAuth flows, and customer API scripts. You will help customers with SQL exports, CSV imports, and configuration questions. Occasionally you will write small scripts in Python to diagnose or fix data issues. You will spot patterns in tickets and push for permanent fixes rather than repeated workarounds. The ideal candidate is patient, technically curious, and a clear writer under pressure.",
  # Associate Product Manager
  "Learn to own a product area while working closely with engineering, design, and data. You will help write specs, define acceptance criteria, and keep the backlog in Jira healthy. Discovery work will involve customer interviews, competitive analysis, and reviewing usage data in Amplitude. You will partner with designers in Figma to shape solutions before they reach engineering. Working with analysts, you will define success metrics and monitor them after launch. You will run sprint ceremonies, unblock the team, and communicate status to stakeholders. Writing clear, concise documents in Notion will be a core skill you build here. You will help prioritize using frameworks like RICE and tie decisions back to company goals. A/B tests will inform your roadmap, and you will learn to interpret results honestly. A senior PM will mentor you and gradually hand over more ownership. This role is for someone early in their product career who is analytical, curious, and a strong communicator.",
  # Mobile Developer
  "Build and maintain our mobile apps for iOS and Android used by thousands of people daily. You will work in React Native with TypeScript, sharing code across platforms where sensible. Native modules in Swift and Kotlin will be needed for camera, notifications, and performance-critical paths. State management uses Redux Toolkit, and networking goes through a typed REST and GraphQL layer. You will handle offline support, background sync, and push notifications with Firebase. Testing includes Jest, React Native Testing Library, and Detox for end-to-end flows on devices. Releases go through App Store Connect and Google Play, and you will help manage the review process. Crash reporting and performance monitoring run through Sentry and Firebase Performance. You will profile and fix jank, memory leaks, and slow startup times. Accessibility on mobile, including screen readers and dynamic type, is part of your work. The ideal candidate cares about the feel of an app, not just whether it functions.",
  # Cloud Engineer
  "Design and operate the cloud foundation that our products are built on. You will work primarily on AWS, with services including EC2, Lambda, RDS, S3, and CloudFront. Infrastructure is defined with Terraform, and you will help move remaining manual resources into code. You will design networking, including VPCs, security groups, and private connectivity to partners. Cost, reliability, and security are the three lenses you will apply to every design. You will build serverless data pipelines with Lambda, SQS, and EventBridge. Monitoring and alerting run through CloudWatch, Grafana, and PagerDuty. You will implement backup, disaster recovery, and multi-region strategies for critical systems. IAM design, encryption with KMS, and compliance guardrails will be part of your remit. You will document architecture and run internal sessions to share cloud best practices. The ideal candidate has strong fundamentals in networking, Linux, and distributed systems.",
  # Junior Data Engineer
  "Help build and maintain the pipelines that move and shape data across the company. You will write Python and SQL to build ingestion jobs from APIs, databases, and files. Our warehouse is Snowflake, and transformations are modeled with dbt in version control. Orchestration runs on Airflow, and you will learn to build, schedule, and monitor DAGs. You will help load data into staging areas from sources like PostgreSQL, Stripe, and Salesforce. Data quality checks, tests, and documentation are expected for every model you build. You will work with analysts to understand how the data is used downstream. Infrastructure runs on AWS with S3 as the data lake, and jobs are containerized with Docker. You will monitor pipeline health and help debug late or missing data. A senior engineer will mentor you on modeling, performance, and best practices. This role suits someone with some Python and SQL who wants to grow into data engineering.",
  # Business Analyst
  "Bridge business needs and technical delivery by turning goals into clear requirements. You will gather requirements through stakeholder interviews, workshops, and process mapping. Documentation will live in Confluence, with user stories and acceptance criteria tracked in Jira. You will write SQL to pull data that supports business cases and validates assumptions. Process diagrams in Lucidchart or Miro will help teams see current and future workflows. You will build models and dashboards in Excel and Power BI to support decisions. Working with product and engineering, you will clarify scope and keep requirements traceable. You will help define KPIs and measure whether delivered work moved them. Cost-benefit analysis and light financial modeling will support prioritization. You will facilitate meetings, capture decisions, and follow up on action items. The ideal candidate is structured, an excellent communicator, and comfortable with data."
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
      location: ["Tokyo","Osaka"].sample,
      salary: ["JPY 3M - 4M", "JPY 4M - 5M", "N/A"].sample,
      job_url: "https://www.accenture.com/us-en/careers/jobdetails?id=R00333866_en&title=SAP+Intercompany+Manager+-+Life+Sciences",
      source_url: "https://www.accenture.com/us-en/careers/jobdetails?id=R00333866_en&title=SAP+Intercompany+Manager+-+Life+Sciences"
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
