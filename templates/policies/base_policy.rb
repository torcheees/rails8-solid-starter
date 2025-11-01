# frozen_string_literal: true

# Example Pundit policy with quota enforcement
class ExampleModelPolicy < ApplicationPolicy
  # Scope for index actions
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin_of?(organization)
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  # GET /example_models
  def index?
    user_is_member?
  end

  # GET /example_models/:id
  def show?
    user_is_member? && (user_is_admin? || record.user_id == user.id)
  end

  # GET /example_models/new
  def new?
    create?
  end

  # POST /example_models
  def create?
    user_is_member? && organization.within_quota?(:example_models)
  end

  # GET /example_models/:id/edit
  def edit?
    update?
  end

  # PATCH/PUT /example_models/:id
  def update?
    user_is_admin? || record.user_id == user.id
  end

  # DELETE /example_models/:id
  def destroy?
    user_is_admin? || record.user_id == user.id
  end

  private

  def organization
    @organization ||= Current.organization || user.current_organization
  end

  def user_is_member?
    user.member_of?(organization)
  end

  def user_is_admin?
    user.admin_of?(organization)
  end
end
