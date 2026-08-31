class AddEmploymentTypeToJobOpenings < ActiveRecord::Migration[8.1]
  def change
    add_column :job_openings, :employment_type, :string
  end
end
