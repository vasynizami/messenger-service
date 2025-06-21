class MessageSerializer
  def initialize(message)
    @message = message
  end

  def as_json
    {
      id: @message.id,
      phone_number: format_phone_number(@message.phone_number),
      text: @message.text,
      status: @message.status,
      created_at: @message.created_at
    }
  end

  def self.serialize(messages)
    if messages.respond_to?(:map)
      messages.map { |msg| new(msg).as_json }
    else
      new(messages).as_json
    end
  end

  private

  def format_phone_number(phone)
    # Remove +1 prefix if present
    phone&.gsub(/^\+1/, '')
  end
end 