class JobOpening < ApplicationRecord
  belongs_to :company
  has_many :applications

  validates :title, presence: true
end
