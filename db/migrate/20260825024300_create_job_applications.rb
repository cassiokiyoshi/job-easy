class CreateJobApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :job_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :job_opening, null: false, foreign_key: true

      t.timestamps
    end
  end
end
