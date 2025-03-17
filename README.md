# Vacation Manager API

This is a REST API built with Ruby on Rails to manage employee time-off requests (vacations and sick leaves). The API includes authentication, pagination, filters, and the ability to calculate the total vacation days an employee has taken per year.

The frontend repository for this API is [this](https://github.com/SegundoRP/vacation-manager-frontend).

The URL in production for this API is "https://vacationsapi-production.up.railway.app/".

## Requirements

- Ruby 3.3.5
- Rails 7.2.2
- PostgreSQL

## Installation

1. Clone the repository:

  ```bash
    git@github.com:SegundoRP/vacations_api.git
    cd vacations_api
  ```

2. Install dependencies:

  ```bash
    bundle install
  ```
3. Set up the database:

  ```bash
  rails db:create
  rails db:migrate
  ```

4. Import initial data from a Google Sheet:

  ```bash
  rake db:seed_from_google_sheet
  ```

5. Start the server:

  ```bash
  rails server
  ```

2. Install dependencies:

  ```bash
  bundle install
  ```

## Endpoints

### Authentication

#### User Registration

- Method: POST
- URL: /auth
- Body:

  ```bash
    {
      "name": "User Name",
      "email": "user@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  ```

#### User Login

- Method: POST
- URL: /auth/sign_in
- Body:

  ```bash
    {
      "email": "user@example.com",
      "password": "password123"
    }
  ```

#### User Registration

- Method: POST
- URL: /auth
- Body:

  ```bash
    {
      "name": "User Name",
      "email": "user@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  ```
#### User Logout

- Method: DELETE
- URL: /auth/sign_out
- Headers:
  - access-token
  - client
  - uid

### Time-Off Requests (TimeOffRequests)

#### List Time-Off Requests
- Method: GET
- URL: /api/v1/time_off_requests
- Headers:
  - access-token
  - client
  - uid

- Optional Parameters:
  - filters[status_eq]: Filter by status (approved, rejected).
  - filters[request_type_eq]: Filter by request type (vacation, incapacity).
  - filters[start_date_gteq]: Filter by start date greater than or equal to.
  - filters[start_date_lteq]: Filter by start date less than or equal to.
  - page: Page number for pagination.
  - per_page: Number of items per page.


  #### Get a Single Time-Off Request
- Method: GET
- URL: /api/v1/time_off_requests/:id
- Headers:
  - access-token
  - client
  - uid


  #### Create a Time-Off Request
- Method: POST
- URL: /api/v1/time_off_requests
- Headers:
  - access-token
  - client
  - uid

- Body:

```bash
{
  "start_date": "2023-10-10",
  "end_date": "2023-10-15",
  "request_type": "vacation",
  "status": "approved",
  "reason": "Family vacation",
  "user_id": 1
}
```




  #### Update a Time-Off Request
- Method: PUT
- URL: /api/v1/time_off_requests/:id
- Headers:
  - access-token
  - client
  - uid`

- Body:

```bash
  {
    "status": "rejected"
  }
```




  #### Delete a Time-Off Request
- Method: DELETE
- URL: /api/v1/time_off_requests/:id
- Headers:
  - access-token
  - client
  - uid

### Users (Users)

#### Get Vacation Days by Year
- Method: GET
- URL: /api/v1/users/:id/vacation_days
- Parameters:
  - year: The year for which to calculate vacation days.

- Headers:
  - access-token
  - client
  - uid

- Body:

```bash
  {
    "user_id": 1,
    "name": "User Name",
    "year": 2023,
    "vacation_days": 10
  }
```

## Data Import from Google Sheets

The application includes a service to import data from a Google Sheet and save it to the database. This service can be run with the following command:

```bash
rails db:seed_from_google_sheet
```

## Gems Used

- Authentication: devise_token_auth
- Pagination: kaminari
- Filters: ransack
- Data Import: roo
- JSON API Serialization: jsonapi-resources
- CORS: rack-cors

## Testing

To run the test suite, use the following command:

```bash
bundle exec rspec
```

## Example Usage

Get Vacation Days for a User

```bash
curl -v \
     -H "access-token: <ACCESS_TOKEN>" \
     -H "client: <CLIENT>" \
     -H "uid: <EMAIL>" \
     -H "Content-Type: application/json" \
     -X GET http://localhost:3000/api/v1/users/1/vacation_days?year=2023 | jq
```



List Time-Off Requests

```bash
curl -v \
     -H "access-token: <ACCESS_TOKEN>" \
     -H "client: <CLIENT>" \
     -H "uid: <EMAIL>" \
     -H "Content-Type: application/json" \
     -X GET http://localhost:3000/api/v1/time_off_requests\?filters%5Bstatus_eq%5D\=0 | jq
```
