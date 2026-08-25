class CreateJobOpenings < ActiveRecord::Migration[8.1]
  def change
    create_table :job_openings do |t|
      t.string :title
      t.date :deadline
      t.text :content
      t.references :company, null: false, foreign_key: true
      t.boolean :closed
      t.string :job_url
      t.string :source_url

      t.timestamps
    end
  end
end
