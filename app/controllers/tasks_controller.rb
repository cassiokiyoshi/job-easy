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
      redirect_back fallback_location: tasks_path, notice: "Task updated."
    else
      redirect_back fallback_location: tasks_path,
                    alert: @task.errors.full_messages.to_sentence
    end
  end

  def destroy
    @task = current_user.tasks.find(params[:id])
    authorize @task

    @task.destroy
    redirect_to tasks_path, notice: "Task deleted."
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

    @application_tasks_by_status =
      application_tasks
      .group_by { |task| task.job_application.status }
      .transform_values do |tasks|
        tasks.group_by(&:job_application)
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
