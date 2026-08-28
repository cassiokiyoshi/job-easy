class ResumePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:job_application)
           .where(job_applications: { user_id: user.id })
    end
  end

  def create?
    true
  end

  def edit?
    record.job_application.user == user
  end

  def update?
    edit?
  end

  def destroy?
    destroy?
  end

  def recommendations?
    edit?
  end

  def dismiss_advice?
    edit?
  end
end
