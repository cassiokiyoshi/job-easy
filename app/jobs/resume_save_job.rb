class ResumeSaveJob < ApplicationJob
  queue_as :default

  def perform(resume_id, file_url)
    resume = Resume.find(resume_id)
    downloaded = URI.open(file_url)

    resume.cv_file.attach(
      io: downloaded,
      filename: resume.cv_file.filename.to_s,
      content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    )
    resume.touch

    Turbo::StreamsChannel.broadcast_replace_to(
      resume,
      target: ActionView::RecordIdentifier.dom_id(resume, :save_status),
      partial: "resumes/save_status",
      locals: { resume: resume, status: "saved" }
    )
  end
end
