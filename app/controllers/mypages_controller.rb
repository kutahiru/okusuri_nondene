class MypagesController < ApplicationController
  before_action :get_user, only: %i[edit update]
  def show
  end

  def edit
  end

  def update
    if @user.update(user_update_params)
      render turbo_stream: [
        turbo_stream.replace(
          @user,
          partial: "mypages/mypage",
          locals: { user: @user }),
        turbo_flash("success", "ユーザーを更新しました")
      ]
    else
      render turbo_stream: turbo_stream.update(
        "modal",
        template: "mypages/edit",
        locals: { user: @user }
      ), status: :unprocessable_entity
    end
  end

  private

  def get_user
    @user = User.find(current_user.id)
  end

  def user_update_params
    params.require(:user).permit(:user_name)
  end
end
