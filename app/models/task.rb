class Task < ApplicationRecord
  belongs_to :user
  belongs_to :job_application, optional: true

  validates :name, presence: true
end
