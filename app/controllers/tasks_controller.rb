class TasksController < ApplicationController
  def index
    @tasks = policy_scope(Task)
  end

  def create
    @task = current_user.tasks.build(task_params)
    authorize @task

    if @task.save
      redirect_to tasks_path
    else
      @tasks = policy_scope(Task)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @task = current_user.tasks.find(params[:id])
    authorize @task

    @task.update(task_params)
    redirect_to tasks_path
  end

  def destroy
    @task = current_user.tasks.find(params[:id])
    authorize @task

    @task.destroy
    redirect_to tasks_path
  end

  private

  def task_params
    params.require(:task).permit(
      :name,
      :completed,
      :position,
      :job_application_id
    )
  end
end
