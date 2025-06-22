require 'jwt'

class Api::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def test
    render json: { message: "Auth controller is working", timestamp: Time.current }
  end

  def login
    begin
      user = User.find_by(email: params[:email])
      
      if user&.valid_password?(params[:password])
        token = generate_token(user)
        render json: { 
          token: token, 
          user: { id: user.id, email: user.email } 
        }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    rescue => e
      Rails.logger.error "Login error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Internal server error: #{e.message}" }, status: :internal_server_error
    end
  end

  def signup
    begin
      user = User.new(email: params[:email], password: params[:password])
      
      if user.save
        token = generate_token(user)
        render json: { 
          token: token, 
          user: { id: user.id, email: user.email } 
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Signup error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Internal server error: #{e.message}" }, status: :internal_server_error
    end
  end

  def logout
    render json: { message: 'Logged out successfully' }
  end

  private

  def generate_token(user)
    begin
      payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
      JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
    rescue => e
      Rails.logger.error "JWT generation error: #{e.message}"
      raise e
    end
  end
end 