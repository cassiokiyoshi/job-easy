class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :name
      t.boolean :completed
      t.references :user, null: false, foreign_key: true
      t.references :job_application, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
