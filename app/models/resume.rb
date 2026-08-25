class Resume < ApplicationRecord
  belongs_to :job_application
  has_one :job_opening, through: :job_application
end
