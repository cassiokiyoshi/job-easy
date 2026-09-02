class Message < ApplicationRecord
  ROLES = %w[user assistant]

  belongs_to :chat

  validates :role, inclusion: { in: ROLES }
  validates :content, presence: true
end
