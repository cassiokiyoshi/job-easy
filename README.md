# Job Easy

Job Easy is a Ruby on Rails application for organizing a job search: browse openings, track applications, manage preparation tasks, and improve resumes with AI assistance.

## Features

- Browse open and closed job listings, filter by source, and view company details.
- Track applications through Saved, Applied, Interviewed, Offered, Accepted, and Rejected stages.
- Manage personal and application tasks, with AI-generated task suggestions.
- Upload DOCX resumes, edit them with ONLYOFFICE, request AI recommendations, and select a default resume.
- Get application-specific AI chat assistance and resume-to-job fit assessments.
- Schedule interviews and practice with an AI interview coach.
- Manage your account through Devise, with access control provided by Pundit.

## Stack

- Ruby **3.3.5** (see `.ruby-version`) and Rails **8.1.3.1** (locked version)
- PostgreSQL
- ERB, Hotwire (Turbo and Stimulus), and import maps
- Bootstrap 5.3, Sass, and Font Awesome
- Solid Queue, Solid Cache, and Solid Cable
- Active Storage with Cloudinary for development and production uploads
- RubyLLM with OpenAI, and ONLYOFFICE Document Server for resume editing

## Local setup

Install Ruby 3.3.5, Bundler 4.0.15 (the lockfile version), and PostgreSQL. Start PostgreSQL and ensure your local database role can create databases. Native gems also require a compiler toolchain and PostgreSQL client development libraries.

```sh
git clone git@github.com:cassiokiyoshi/job-easy.git
cd job-easy
gem install bundler -v 4.0.15
bundle install
```

Create a `.env` file in the project root with your service configuration:

```dotenv
ONLYOFFICE_SERVER_URL=https://your-document-server.example.com
ONLYOFFICE_JWT_SECRET=replace-with-your-document-server-jwt-secret
ONLYOFFICE_JWT_HEADER=Authorization
OPENAI_API_KEY=replace-with-your-openai-api-key
CLOUDINARY_URL=cloudinary://API_KEY:API_SECRET@CLOUD_NAME
```

`ONLYOFFICE_SERVER_URL` and `ONLYOFFICE_JWT_SECRET` must be set before Rails can boot, including for tests, because the initializers use `ENV.fetch`. The JWT header defaults to `Authorization`. Working OpenAI credentials are needed for AI features; Cloudinary credentials are needed for uploads and job imports. `.env` files are ignored by Git.

Prepare the database and start the application:

```sh
bin/setup --skip-server
bin/dev
```

Open [localhost:3000](http://localhost:3000). The local databases are `rails_job_easy_development` and `rails_job_easy_test`; connection settings are in `config/database.yml`.

Puma currently starts Solid Queue through `config/puma.rb`, so the development server also processes background jobs. `bin/jobs` is available for running a separate worker when needed.

### Resume editing

Run or connect to an ONLYOFFICE Document Server using the URL and matching JWT secret in `.env`. The document server must be able to fetch uploaded documents and reach the Rails callback endpoint at `/api/resumes/:id/callback`.

The development configuration currently contains a project-specific ngrok hostname. Update the URL defaults and `config.hosts` entry near the end of `config/environments/development.rb` to your own reachable host before using resume editing. For a local Rails server, this typically means exposing port 3000 through a tunnel.

### Sample data and job listings

**The seed script deletes existing tasks, resumes, applications, job openings, companies, and users.** Use it only with a disposable development database. Initial database preparation can run this script when creating a new database.

```sh
bin/rails db:seed
```

The active seed code creates a demo account (`test@mail.com` / `secret`). The sample company and application creation code is currently commented out.

To populate listings from the checked-in CFN, Wantedly, and JapanDev JSON snapshots:

```sh
bin/rails jobs:update
```

This task imports the snapshot files selected in `lib/tasks/jobs.rake`; it does not scrape fresh listings. It downloads company logos, so it needs network access and working Cloudinary credentials. Listing deadlines come from the snapshots, and expired listings are marked closed.

## Development checks

With the environment configured and PostgreSQL running:

```sh
bin/rails db:test:prepare
bin/rails test
bin/rubocop
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
bin/bundler-audit
bin/importmap audit
```

`bin/ci` runs the checks defined in `config/ci.rb`, including setup and a test-database seed replant. System tests can be run separately with `bin/rails test:system` and require a compatible browser and driver.

## Project layout

| Path | Purpose |
| --- | --- |
| `app/controllers/` | Web requests, resume callbacks, and interview preparation |
| `app/models/` | Users, companies, openings, applications, resumes, tasks, and chats |
| `app/services/ai/` | Task suggestions, application chat, fit assessments, and interview coaching |
| `app/jobs/` | Background AI responses and resume saving |
| `app/policies/` | Pundit authorization rules |
| `app/views/` | ERB pages and Turbo updates |
| `app/javascript/controllers/` | Stimulus interactions |
| `db/scrapes/` | Job listing snapshots |
| `lib/tasks/jobs.rake` | Job import task |
| `test/` | Rails tests |

## Deployment configuration

The repository includes a production Dockerfile and Kamal configuration. Review those settings for your deployment environment. Production uses `DATABASE_URL` for the primary, cache, queue, and cable connections, and needs the service configuration described above plus the Rails credentials key (`RAILS_MASTER_KEY`) when using encrypted credentials.

## Credits

Originally generated with [Le Wagon's Rails templates](https://github.com/lewagon/rails-templates).
