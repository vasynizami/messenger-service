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
      client = Twilio::REST::Client.new(
        ENV['TWILIO_ACCOUNT_SID'],
        ENV['TWILIO_AUTH_TOKEN']
      )

      twilio_message = client.account.messages.create(
        from: ENV['TWILIO_PHONE_NUMBER'],
        to: "+#{message.phone_number}",
        body: message.text
      )

      message.update(status: 'sent', twilio_sid: twilio_message.sid)
    rescue StandardError => e
      message.update(status: 'failed')
      Rails.logger.error "SMS sending error: #{e.message}"
    end
  end
end 