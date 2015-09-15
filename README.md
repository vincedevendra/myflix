##MyFlix
[![Circle CI](https://circleci.com/gh/vincedevendra/myflix.svg?style=svg)](https://circleci.com/gh/vincedevendra/myflix)

### A Netflix Clone, created as part of the curriculum at Tealeaf Academy

## Features

### Registration, Authentication, and Payments

-  Hand-rolled authentication, using `bcrypt` for password encryption.
-  Uses Stripe API for subscribing customers to the monthly plan, storing and charging credit cards
-  Disable or limit user access when payments fail and send earning emails.
-  Funnels users to account details page when payments fail so that they can update payment information.
-  Sends a welcome email upon registration.

### Queue
-  Users can add videos to watch later, as well as delete or reorder them.

### People
-  Users can create reviews and ratings for videos, which display on video pages.
-  Users can follow other users, so that they can view their queues and video reviews.
-  Users can invite their friends, which sends an email to them, keeps track of the invitation.  If their friend joins, each user will automatically follow the other.

### Admin
-  Admin can add videos, including uploading video images.
-  Admin can view recent user payments

##Under the Hood

###Database
-  Uses Postgres in both development and production

### Testing
-  Comprehensive unit, controller, and integration test coverage using RSpec and Capybara
-  Uses `vcr` gem to keep track of api responses
- Uses `selenium` and `capybara-webkit` to process javascript
- Employs stubs and mocks to avoid redundant testing

### Beyond the Basics
-  Concerns to keep models DRY
-  API Wrapper for Stripe
-  Webhook processing for Stripe, using `stripe-events` gem
-  Service object to push complex registration workflow out of controllers
-  Decorators using `draper` gem to push view logic out of models
-  Advanced search using the Elasticsearch API
-  Sikdekiq for service worker to delay email sending
-  File Uploading using `carrierwave` gem with `aws` to handle video image uploading and resizing.

###Deployment and Coding Environment

- Created using the Github workflow
- Continuous Integration and Deployment with Circle CI
-  Uses unicorn server
-  Uses `foreman` to start up server and auxiliary services
- Deployed with Heroku
    -  Staging app to test changes in production environment before pushing to production app
- Uses Raven to monitor production server errors.


## See it in the Wild!
Deployed on [Heroku](http://vince-tl-myflix.herokuapp.com)

<small>NB: Front end supplied by the Tealeaf team.</small>
