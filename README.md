# SMS Messenger Service

A Rails API backend for sending SMS messages via Twilio with user authentication.

## Setup

1. Install dependencies: `bundle install`
2. Configure Twilio credentials: `rails credentials:edit`
3. Start server: `rails server`
4. Create test user: `rails console` then `User.create!(email: 'test@example.com', password: 'password123')`

## API Endpoints

### Authentication

#### Login

**POST** `/api/login`

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Logout

**POST** `/api/logout`
Headers: `Authorization: Bearer <token>`

### Messages

#### Send SMS

**POST** `/api/messages`
Headers: `Authorization: Bearer <token>`

```json
{
  "phone_number": "234567890",
  "text": "Hello from the API!"
}
```

#### List Messages

**GET** `/api/messages`
Headers: `Authorization: Bearer <token>`

## Message Statuses

Messages can have the following Twilio statuses:

- `accepted` - Message accepted by Twilio
- `queued` - Message queued for delivery
- `sending` - Message being sent
- `sent` - Message sent to carrier
- `delivered` - Message delivered to recipient
- `undelivered` - Message failed to deliver
- `failed` - Message failed to send
- `read` - Message read by recipient (SMS only)

## Twilio Setup

Add to credentials: `rails credentials:edit`

```yaml
twilio:
  account_sid: your_sid
  auth_token: your_token
  phone_number: your_number
```

## Features

- User authentication with JWT tokens
- SMS sending via Twilio API
- Message storage and retrieval per user
- RESTful API endpoints
- CORS support for frontend integration

## Frontend Integration

### CORS Configuration

The API is configured to accept requests from any origin. In production, update `config/initializers/cors.rb` to restrict origins to your frontend domain.

### Example Frontend Usage

```javascript
// Login
const loginResponse = await fetch("/api/login", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ email: "user@example.com", password: "password" }),
});
const { token } = await loginResponse.json();

// Send SMS
const sendResponse = await fetch("/api/messages", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    message: {
      phone_number: "+1234567890",
      text: "Hello from frontend!",
    },
  }),
});

// List messages
const messagesResponse = await fetch("/api/messages", {
  headers: { Authorization: `Bearer ${token}` },
});
const messages = await messagesResponse.json();
```

## Development

### Creating a Test User

```bash
rails console
```

```ruby
User.create!(email: 'test@example.com', password: 'password123')
```

### Testing the API

Visit `http://localhost:3000` to see the API documentation.

## Production Deployment

1. Set up your production database
2. Configure Twilio credentials in production
3. Update CORS origins to your frontend domain
4. Set `RAILS_ENV=production`
5. Deploy using your preferred method (Heroku, AWS, etc.)

## Security Notes

- JWT tokens expire after 24 hours
- Passwords are encrypted using Devise
- Phone numbers are validated for proper format
- Messages are scoped to authenticated users only
