class AddVerdictAndDefaultResume < ActiveRecord::Migration[8.1]
  def change
    add_column :resumes, :is_default, :boolean, default: false
    add_index :resumes, :is_default

    add_column :job_applications, :verdict, :text
    add_column :job_applications, :verdict_generated_at, :datetime
  end
end
