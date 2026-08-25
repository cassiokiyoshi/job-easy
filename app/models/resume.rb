class Resume < ApplicationRecord
  belongs_to :job_application
  has_one :job_opening, through: :job_application
  has_one_attached :cv_file
end
