class AddCallbackTokenToResumes < ActiveRecord::Migration[8.1]
  def change
    add_column :resumes, :callback_token, :string
  end
end
