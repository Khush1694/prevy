class StaticPagesController < ApplicationController
  def home
    if signed_in?
      store_user_events
      store_user_groups
    end

    store_unhidden_groups
  end

  private

    def store_user_events
      @user         = User.find(current_user.id)
      user_events   = @user.events_from_groups
      @events_count = user_events.count
      @events       = EventDecorator.collection(user_events.limit(6))
    end

    def store_user_groups
      @user_groups = @user.groups
    end

    def store_unhidden_groups
      @unhidden_groups = Group.unhidden.random_selection(3)
    end
end
