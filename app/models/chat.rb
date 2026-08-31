class Chat < ApplicationRecord
  belongs_to :job_application

  has_many :messages,
           -> { order(:created_at, :id) },
           dependent: :destroy

  validates :job_application_id, uniqueness: true
end
