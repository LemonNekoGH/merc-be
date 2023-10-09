# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def update?
    ownership?
  end

  def ownership?
    return false if user.nil?

    user == record
  end
end
