class User < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_many :job_applications, dependent: :destroy
  has_many :resumes, through: :job_applications
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
