class Api::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def status_callback
    Rails.logger.info "Webhook received: #{params.inspect}"
    
    message_sid = params[:MessageSid]
    message_status = params[:MessageStatus]

    Rails.logger.info "Looking for message with SID: #{message_sid}, status: #{message_status}"

    message = Message.find_by(twilio_sid: message_sid)
    
    if message
      message.update(status: message_status)
      Rails.logger.info "Updated message #{message_sid} status to #{message_status}"
    else
      Rails.logger.warn "Message not found for SID: #{message_sid}"
    end
    
    render json: { status: 'ok' }
  end
end 