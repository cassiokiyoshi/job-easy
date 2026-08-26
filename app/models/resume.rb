class Resume < ApplicationRecord
  belongs_to :job_application
  has_one :job_opening, through: :job_application
  has_one_attached :cv_file

  before_create :generate_callback_token

  def onlyoffice_key
    "#{id}-#{updated_at.to_i}"
  end

  private

  def generate_callback_token
    self.callback_token = SecureRandom.hex(16)
  end
end
