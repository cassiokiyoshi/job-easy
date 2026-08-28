class AddSalaryAndLocationToJobOpenings < ActiveRecord::Migration[8.1]
  def change
    add_column :job_openings, :salary, :string
    add_column :job_openings, :location, :string
  end
end
