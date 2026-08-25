class Task < ApplicationRecord
  belongs_to :user
  belongs_to :job_application

  validates :name, presence: true
end
