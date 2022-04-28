class ActivitiesController < ApplicationController
  def index
    @activities = current_user.active_notifications.page(params[:page]).per(5)
  end
end
