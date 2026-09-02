class Resume < ApplicationRecord
  belongs_to :job_application
  has_one :job_opening, through: :job_application
  has_one_attached :cv_file

  before_create :generate_callback_token

  scope :default, -> { where(is_default: true) }

  def onlyoffice_key
    "#{id}-#{updated_at.to_i}"
  end

  # Marks this resume as the user's single default, clearing the flag on
  # every other resume the user owns.
  def make_default!
    job_application.user.resumes.where.not(id: id).update_all(is_default: false)
    update!(is_default: true)
  end

  private

  def generate_callback_token
    self.callback_token = SecureRandom.hex(16)
  end
end
