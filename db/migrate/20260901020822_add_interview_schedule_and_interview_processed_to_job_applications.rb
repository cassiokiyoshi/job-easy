class AddInterviewScheduleAndInterviewProcessedToJobApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :job_applications, :interview_schedule, :datetime, array: true, default: []
    add_column :job_applications, :interviews_processed, :integer, default: 0
  end
end
