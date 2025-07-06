class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  # CSRF protection
  protect_from_forgery with: :exception

  add_flash_types :success, :error, :info, :warning

  include TurboFlashMessages
end
