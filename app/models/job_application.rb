class JobApplication < ApplicationRecord
  belongs_to :user, :job_opening
  has_one :resume
  has_many :tasks

  STATUS = ["Saved", "Applied", "Interviewed", "Offer", "Accepted", "Rejected"]

  attribute :status, :string, default: "Saved"
  validates :status, inclusion: { in: STATUS }
end
