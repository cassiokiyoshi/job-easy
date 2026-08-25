class Company < ApplicationRecord
  has_many :job_openings, dependent: :destroy

  validates :name, presence: true
end
