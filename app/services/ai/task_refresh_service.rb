module Ai
  class TaskRefreshService
    def initialize(job_application)
      @job_application = job_application
    end

    def call
      # Generate and validate the plan before changing any tasks.
      # If AI fails, existing tasks remain untouched.
      plan = TaskSuggestionService.new(job_application).refresh_plan

      Task.transaction do
        remove_obsolete_tasks(plan[:keep_task_ids])
        create_suggestions(plan[:suggestions])
      end

      plan
    end

    private

    attr_reader :job_application

    def remove_obsolete_tasks(keep_task_ids)
      job_application.tasks
                     .where(completed: false)
                     .where.not(id: keep_task_ids)
                     .destroy_all
    end

    def create_suggestions(suggestions)
      suggestions.each do |suggestion|
        job_application.tasks.create!(
          user: job_application.user,
          name: suggestion
        )
      end
    end
  end
end
