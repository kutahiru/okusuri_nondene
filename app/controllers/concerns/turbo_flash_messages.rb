module TurboFlashMessages
  extend ActiveSupport::Concern

  private

  def turbo_flash(message_type, message)
    turbo_stream.prepend("flash-container", partial: "shared/flash_message_item", locals: {
      message_type: message_type,
      message: message
    })
  end
end
