class JobOpening < ApplicationRecord
  belongs_to :company
  has_many :applications

  validates :title, presence: true

  scope :ordered, -> { order(deadline: :asc) }
  scope :open, -> { where(closed: false) }
  scope :close, -> { where(closed: true) }
end
