class Api::MessagesController < Api::BaseController
  def index
    messages = current_user.messages.order(created_at: :desc)
    render json: MessageSerializer.serialize(messages)
  end

  def create
    message = current_user.messages.build(message_params)
    
    if message.save
      send_sms(message)
      render json: MessageSerializer.serialize(message), status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:phone_number, :text)
  end

  def send_sms(message)
    begin
      Rails.logger.info "Starting SMS send for message #{message.id}"
      Rails.logger.info "Twilio credentials check: SID=#{ENV['TWILIO_ACCOUNT_SID']&.first(10)}..., TOKEN=#{ENV['TWILIO_AUTH_TOKEN']&.first(10)}..., PHONE=#{ENV['TWILIO_PHONE_NUMBER']}"

      unless ENV['TWILIO_ACCOUNT_SID'] && ENV['TWILIO_AUTH_TOKEN'] && ENV['TWILIO_PHONE_NUMBER']
        Rails.logger.error "Missing Twilio environment variables"
        message.update(status: 'failed')
        return
      end

      client = Twilio::REST::Client.new(
        ENV['TWILIO_ACCOUNT_SID'],
        ENV['TWILIO_AUTH_TOKEN']
      )

      status_callback_url = Rails.env.production? ? 
      "https://messenger-service-production-4d91.up.railway.app/api/webhooks/status" : 
      "#{request.base_url}/api/webhooks/status"
      
      Rails.logger.info "Sending SMS to +#{message.phone_number} with callback URL: #{status_callback_url}"
      
      twilio_message = client.account.messages.create(
        from: ENV['TWILIO_PHONE_NUMBER'],
        to: "+#{message.phone_number}",
        body: message.text,
        status_callback: status_callback_url
      )

      Rails.logger.info "Twilio message created successfully: #{twilio_message.sid}"
      message.update(status: 'pending', twilio_sid: twilio_message.sid)
    rescue StandardError => e
      Rails.logger.error "SMS sending error: #{e.message}"
      Rails.logger.error "Error backtrace: #{e.backtrace.first(5).join("\n")}"
      message.update(status: 'failed')
    end
  end
end 