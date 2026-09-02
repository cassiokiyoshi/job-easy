class GenerateVerdictJob < ApplicationJob
  queue_as :default

  def perform(job_application_id)
    job_application = JobApplication.find_by(id: job_application_id)
    return unless job_application

    resume = job_application.user.default_resume
    return unless resume&.cv_file&.attached?

    resume.update!(content: Resumes::TextExtractor.new(resume).call) if resume.content.blank?

    job_application.update!(
      verdict: Ai::VerdictService.new(job_application).call,
      verdict_generated_at: Time.current
    )
  end
end
