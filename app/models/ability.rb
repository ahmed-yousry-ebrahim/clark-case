class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil? #guest user
      guest
    else #authenticated user
      authenticated(user)
      if user.is_admin?
        admin
      end
    end
  end

  def guest
    can :read, :all
  end

  def authenticated user
    guest
    can [:create, :toggle_like], [Post, Comment]
    can [:update, :destroy], [Post, Comment], :user_id => user.id
  end

  def admin
    can :manage, :all
  end
end
