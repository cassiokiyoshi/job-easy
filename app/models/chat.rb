class Chat < ApplicationRecord
  belongs_to :job_application

  has_many :messages,
           -> { order(:created_at, :id) },
           dependent: :destroy

  # One chat per purpose per application; the DB enforces uniqueness on
  # [job_application_id, purpose].
  enum :purpose, { general: "general", interview_prep: "interview_prep" }
end
