require "test_helper"

class JobApplicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user("application-owner")
    @application = create_application_for(@user)
    sign_in @user
  end

  test "clears only completed tasks for the application" do
    completed = create_task(@application, "Completed task", completed: true)
    incomplete = create_task(@application, "Incomplete task", completed: false)

    assert_difference "Task.count", -1 do
      delete clear_completed_tasks_job_application_path(@application)
    end

    assert_not Task.exists?(completed.id)
    assert Task.exists?(incomplete.id)
    assert_redirected_to job_application_path(@application)
  end

  test "generates exactly one task for the application" do
    service = Object.new
    service.define_singleton_method(:one_suggestion) { "Prepare one example" }

    with_task_suggestion_service(service) do
      assert_difference "Task.count", 1 do
        post generate_task_job_application_path(@application)
      end
    end

    task = @application.tasks.reload.last
    assert_equal "Prepare one example", task.name
    assert_equal @user, task.user
    assert_redirected_to tasks_path
  end

  private

  def with_task_suggestion_service(service)
    singleton_class = Ai::TaskSuggestionService.singleton_class
    original_new = Ai::TaskSuggestionService.method(:new)
    singleton_class.define_method(:new) { |*| service }
    yield
  ensure
    singleton_class.define_method(:new, original_new)
  end

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

  def create_task(application, name, completed:)
    application.tasks.create!(user: @user, name:, completed:)
  end
end
