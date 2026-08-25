class CreateResumes < ActiveRecord::Migration[8.1]
  def change
    create_table :resumes do |t|
      t.references :job_application, null: false, foreign_key: true
      t.jsonb :ai_response
      t.text :content

      t.timestamps
    end
  end
end
