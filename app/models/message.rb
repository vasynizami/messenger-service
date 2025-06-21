class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :phone_number, type: String
  field :text, type: String
  field :status, type: String, default: 'pending'
  field :twilio_sid, type: String

  belongs_to :user

  validates :phone_number, presence: true, format: { with: /\A\+?[1-9]\d{1,14}\z/, message: "must be a valid phone number" }
  validates :text, presence: true, length: { maximum: 250 }
  validates :user, presence: true
end
