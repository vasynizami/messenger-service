require 'test_helper'

class Api::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    User.delete_all
    Message.delete_all

    @user = User.create!(email: 'test@example.com', password: 'password123')
    @token = generate_token(@user)
  end

  test "should get index" do
    get api_messages_url, headers: { 'Authorization': "Bearer #{@token}" }
    assert_response :success
  end

  test "should create message" do
    assert_difference('Message.count') do
      post api_messages_url, params: { 
        message: {
          phone_number: '1234567890', 
          text: 'Test message' 
        }
      }.to_json, headers: { 
        'Authorization': "Bearer #{@token}",
        'Content-Type': 'application/json'
      }
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal '1234567890', json_response['phone_number']
    assert_equal 'Test message', json_response['text']
    assert_equal 'pending', json_response['status'] 
  end

  test "should not create message without authentication" do
    post api_messages_url, params: { 
      message: {
        phone_number: '1234567890', 
        text: 'Test message' 
      }
    }.to_json
    assert_response :unauthorized
  end

  test "should not create message with invalid phone number" do
    post api_messages_url, params: { 
      message: {
        phone_number: 'invalid', 
        text: 'Test message' 
      }
    }.to_json, headers: { 
      'Authorization': "Bearer #{@token}",
      'Content-Type': 'application/json'
    }
    assert_response :unprocessable_entity
  end

  private

  def generate_token(user)
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end
end 