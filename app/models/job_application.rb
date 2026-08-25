class JobApplication < ApplicationRecord
  belongs_to :user
  belongs_to :job_opening
  has_one :resume
  has_many :tasks, dependent: :destroy

  enum :status,
       { saved: "Saved", applied: "Applied", interviewed: "Interviewed", offered: "Offered", accepted: "Accepted",
         rejected: "Rejected" }

  attribute :status, :string, default: "Saved"
  validates :status, presence: true
end
