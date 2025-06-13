module ApplicationHelper
  def format_time_to_hour_minute(target_time)
    target_time.strftime("%H:%M")
  end
end
