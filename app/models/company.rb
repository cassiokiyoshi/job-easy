class Company < ApplicationRecord
  has_many :job_openings, dependent: :destroy
  has_one_attached :logo

  validates :name, presence: true
end
