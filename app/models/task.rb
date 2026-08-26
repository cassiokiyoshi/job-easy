class Task < ApplicationRecord
  belongs_to :user
  belongs_to :job_application, optional: true

  validates :name, presence: true

  validates :name,
            uniqueness: {
              scope: %i[user_id job_application_id],
              case_sensitive: false,
              message: "has already been added to this application"
            },
            if: :job_application_id?
end
