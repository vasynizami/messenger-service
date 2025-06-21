require 'test_helper'

class Api::WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.delete_all
    Message.delete_all

    @message = Message.create!(
      phone_number: '1234567890',
      text: 'Test message',
      status: 'pending',
      twilio_sid: 'SM1234567890abcdef',
      user: User.create!(email: 'test@example.com', password: 'password123')
    )
  end

  test "should update message status via webhook" do
    post'/api/webhooks/status', params: {
      MessageSid: 'SM1234567890abcdef',
      MessageStatus: 'delivered'
    }

    assert_response :success
    @message.reload
    assert_equal 'delivered', @message.status
  end
end