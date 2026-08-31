class CreateChats < ActiveRecord::Migration[8.1]
  def change
    create_table :chats do |t|
      t.references :job_application,
             null: false,
             foreign_key: true,
             index: { unique: true }

      t.timestamps
    end
  end
end
