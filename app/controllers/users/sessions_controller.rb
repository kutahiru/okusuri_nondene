class Users::SessionsController < Devise::SessionsController
  def destroy
    reset_session
    redirect_to root_path, info: "ログアウトしました"
  end
end
