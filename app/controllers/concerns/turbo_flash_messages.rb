module TurboFlashMessages
  extend ActiveSupport::Concern

  private

  def turbo_flash(message_type, message)
    turbo_stream.update("flash-container", partial: "shared/flash_message_item", locals: {
      message_type: message_type,
      message: message
    })
  end

  # エラー時にrenderする場合
  def turbo_flash_and_stop(message_type, message)
    render turbo_stream: turbo_flash(message_type, message), status: :unprocessable_entity
  end
end
