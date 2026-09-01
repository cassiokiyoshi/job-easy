class AddSourceToJobOpenings < ActiveRecord::Migration[8.1]
  def change
    add_column :job_openings, :source, :string
  end
end
