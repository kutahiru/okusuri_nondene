class MedicationManagementsController < ApplicationController
  def index
    @medication_group = current_user.medication_groups.find(params[:medication_group_id])

    # 年月の取得（デフォルトは今月）
    year = params["year"].to_i
    month = params["month"].to_i
    @target_date = begin
      Date.new(year, month, 1)
    rescue ArgumentError
      Date.current
    end

    # カレンダーの日付リストを生成
    @calendar_days = (@target_date.beginning_of_month..@target_date.end_of_month).map do |date|
      {
        date: date,
        day: date.day,
        wday_name: %w[日 月 火 水 木 金 土][date.wday],
        display: "#{date.day}日(#{%w[日 月 火 水 木 金 土][date.wday]})",
        is_today: date == Date.current,
        is_weekend: date.saturday? || date.sunday?
      }
    end

    @medication_managements = @medication_group.medication_managements
      .for_month(@target_date)

    # 日付別にグループ化
    @medications_by_date = @medication_managements.group_by(&:medication_date)
  end
end
