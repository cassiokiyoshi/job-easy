class TasksController < ApplicationController
  def index
    load_index_data
  end

  def create
    @task = current_user.tasks.build(task_params)
    authorize @task

    if @task.save
      redirect_to tasks_path, notice: "Task added."
    else
      load_index_data
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @task = current_user.tasks.find(params[:id])
    authorize @task

    if @task.update(task_params)
      respond_to do |format|
        format.turbo_stream do
          head :no_content
        end
        format.html do
          redirect_back fallback_location: tasks_path, notice: "Task updated."
        end
      end
    else
      redirect_back fallback_location: tasks_path,
                    alert: @task.errors.full_messages.to_sentence
    end
  end

  def destroy
    @task = current_user.tasks.find(params[:id])
    authorize @task

    @task.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@task)
      end
      format.html do
        redirect_to tasks_path, notice: "Task deleted."
      end
    end
  end

  def clear_completed_application
    authorize current_user.tasks.build, :destroy?
    completed_tasks = policy_scope(Task)
                      .where(completed: true)
                      .where.not(job_application_id: nil)
    removed_count = completed_tasks.destroy_all.size

    redirect_to tasks_path,
                notice: "#{removed_count} completed application task(s) cleared.",
                status: :see_other
  end

  def clear_completed_personal
    authorize current_user.tasks.build, :destroy?
    completed_tasks = policy_scope(Task)
                      .where(completed: true, job_application_id: nil)
    removed_count = completed_tasks.destroy_all.size

    redirect_to tasks_path,
                notice: "#{removed_count} completed personal task(s) cleared.",
                status: :see_other
  end

  private

  def load_index_data
    @tasks = policy_scope(Task)
             .includes(job_application: { job_opening: :company })
             .order(:completed, :position, :created_at)

    @task ||= current_user.tasks.build

    @job_applications = policy_scope(JobApplication)
                        .includes(job_opening: :company)
                        .order(created_at: :desc)

    @personal_tasks = @tasks.select do |task|
      task.job_application_id.nil?
    end

    application_tasks = @tasks.reject do |task|
      task.job_application_id.nil?
    end

    tasks_by_application = application_tasks.group_by(&:job_application)

    @application_tasks_by_status =
      @job_applications
      .group_by(&:status)
      .transform_values do |applications|
        applications.index_with do |application|
          tasks_by_application.fetch(application, [])
        end
      end
  end

  def task_params
    params.require(:task).permit(
      :name,
      :completed,
      :position,
      :job_application_id
    )
  end
end
