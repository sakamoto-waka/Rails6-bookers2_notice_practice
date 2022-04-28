class NotificationsController < ApplicationController
  def index
    # 未通知を取得、未確認を確認済みにする処理
    notifications = current_user.passive_notifications
    notifications.where(checked: false).each do |notification|
      notification.update_attribute(:checked, true)
    end
    @notifications_except_me = notifications.where.not(visitor_id: current_user.id)
  end
end
