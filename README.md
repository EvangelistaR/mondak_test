# Rate Limiter Project
This project implements a rate-limited Notification Service using Ruby on Rails, Redis for rate limiting, and PostgreSQL as the database. It ensures that recipients are not overwhelmed with too many email notifications of various types.

## Table of Contents
- [Requirements](#requirements)
- [Setup](#setup)
- [Running Tests](#running-tests)
- [Implementation Details](#details)
- [Contributing](#contributing)
- [License](#license)

<a id="requirements"></a>
## Requirements

 - Ruby 3.1.0
 - Rails 7.0
 - PostgreSQL
 - Redis
 - Bundler

<a id="setup"></a>
## Setup

- Clone the repository:
  ```bash
  git clone https://github.com/yourusername/notification_rate_limiter.git
  ```
- Install dependencies:
  ```bash
  bundle install
  ```
- Setup the database:
  ```bash
  rails db:create
  rails db:migrate
  ```
- Start the Redis server:
  ```bash
  redis-server
  ```
- Run the Rails server:
  ```bash
  rails server
  ```
<a id="running-tests"></a>
## Running Tests

To run the RSpec tests, use the following command:
```bash
rspec
```
<a id="details"></a>
## Impletation Details

### Notification Service
The NotificationService is responsible for sending email notifications. It ensures that the rate limits are respected for each type of notification.

### Rate Limiter Service
The RateLimiter class handles the logic for enforcing rate limits using Redis.

### Notification Types and Rate Limits
- Status: Not more than 2 notifications per minute per recipient.
- News: Not more than 1 notification per day per recipient.
- Marketing: Not more than 3 notifications per hour per recipient.
<a id="contributing"></a>
## Contributing

Feel free to open issues or submit pull requests for any improvements or bug fixes.

<a id="license"></a>
## License

This project is licensed under the MIT License.