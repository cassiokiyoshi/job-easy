require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user("task-owner")
    @other_user = create_user("other-task-owner")
    sign_in @user
  end

  test "clears completed application tasks belonging to the current user" do
    completed_personal = @user.tasks.create!(name: "Done personal", completed: true)
    application = create_application_for(@user)
    completed_application = application.tasks.create!(
      user: @user,
      name: "Done application",
      completed: true
    )
    incomplete = @user.tasks.create!(name: "Still open", completed: false)
    other_task = @other_user.tasks.create!(name: "Someone else's task", completed: true)

    assert_difference "Task.count", -1 do
      delete clear_completed_application_tasks_path
    end

    assert Task.exists?(completed_personal.id)
    assert_not Task.exists?(completed_application.id)
    assert Task.exists?(incomplete.id)
    assert Task.exists?(other_task.id)
    assert_redirected_to tasks_path
  end

  test "clears completed personal tasks without deleting application tasks" do
    completed_personal = @user.tasks.create!(name: "Done personal", completed: true)
    application = create_application_for(@user)
    completed_application = application.tasks.create!(
      user: @user,
      name: "Done application",
      completed: true
    )
    incomplete_personal = @user.tasks.create!(name: "Still open", completed: false)

    assert_difference "Task.count", -1 do
      delete clear_completed_personal_tasks_path
    end

    assert_not Task.exists?(completed_personal.id)
    assert Task.exists?(completed_application.id)
    assert Task.exists?(incomplete_personal.id)
    assert_redirected_to tasks_path
  end

  test "shows a generate-task control for an application without tasks" do
    application = create_application_for(@user)

    get tasks_path

    assert_response :success
    assert_select "form[action='#{generate_task_job_application_path(application)}']"
    assert_select "a.application-task-card__company[href='#{job_application_path(application)}']"
    assert_select "a.application-task-card__link", text: /View/, count: 0
  end

  private

  def create_user(prefix)
    User.create!(
      email: "#{prefix}-#{SecureRandom.hex(4)}@example.com",
      password: "password"
    )
  end

  def create_application_for(user)
    company = Company.create!(name: "Example Company #{SecureRandom.hex(3)}")
    opening = JobOpening.create!(company:, title: "Developer")
    JobApplication.create!(user:, job_opening: opening)
  end
end
