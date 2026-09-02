class AddPurposeToChats < ActiveRecord::Migration[8.1]
  def change
    # A job application can now hold one chat per purpose: the existing
    # "Chat with JobEasy" assistant plus the interview prep coach.
    remove_index :chats, column: :job_application_id, unique: true
    add_column   :chats, :purpose, :string, null: false, default: "general"
    add_index    :chats, [:job_application_id, :purpose], unique: true
  end
end
