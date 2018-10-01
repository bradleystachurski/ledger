# Ledger

Ledger is a Phoenix application written in Elixir that offloads transactions from the main Ethereum network in dedicated off-chain ledgers. These ledgers are represented as payment groups, which allow participants to join, transact with other participants of the payment group, and exit back to the main Ethereum network.

## Dependencies

  - Elixir ~> 1.7.3
  - PostgresSQL

## Installation

  - Install Elixir. The Elixir site maintains a great [Installation Page](https://elixir-lang.org/install.html) to help
  - Install dependencies with `mix deps.get`
  - Install [PostgresSQL](https://www.postgresql.org/download/)
    - If you're using macOS, I recommend [Postgres.app](https://postgresapp.com/)
  
## Running a Server

To start a local server:

  - Start PostgresSQL if it isn't already running
  - Create and migrate your database with `mix ecto.create && mix ecto.migrate`
    - If this fails, you may need to update your database config in `/config/dev.exs` to match your local PostgresSQL config
  - Start the server with `mix phx.server`
    - The default port is `4000`. To start the server on a different port, use `PORT=<port_number> mix phx.server`

You're now running a Phoenix server locally! You can begin using the API with the url `http://localhost:4000/api/groups` (or using whatever port used for startup).

## Testing

Run the test suite with
  
  `mix test`

### Seeding the database

Test data can be created by running
  
  `mix run priv/repo/seeds.exs`

To reset the database and reseed, run

  `mix ecto.reset`

## Health Check

The API allows services such as Amazon's Elastic Load Balancer to monitor the health of deployed instances.

The health check configuration for Amazon's ELB must point to `/api/health`. This endpoint will respond with a "200 OK" status code if it's available.

## API Documentation

### Groups

#### Get All Groups

`GET /api/groups`

Example return payload

```
{
    "data": [
        {
            "name": "ETH",
            "id": 1
        },
        {
            "name": "BTC",
            "id": 2
        }
    ]
}
```

#### Create a Group

`POST /api/groups`

Request body

```
{
	"name": "ETH"
}
```

Example return payload

```
{
    "data": {
        "name": "ETH",
        "id": 1
    }
}
```

#### Get Group by ID

`GET /api/groups/:id`

Example return payload

```
{
    "data": {
        "name": "ETH",
        "id": 1
    }
}
```

#### Get Total Balance of Group

`GET /api/groups/:id/total`

Example return payload

```
{
    "data": {
        "group_total": 200
    }
}
```

#### Remove Group

`DELETE /api/groups/:id`

Note: Groups cannot be removed until all participants have exited

### Participants

#### Add Participant to Group

`POST /api/groups/:group_id/participants`

Request body

```
{
	"username": "alice",
	"amount": 100
}
```

Example return payload

```
{
    "data": {
        "username": "alice",
        "id": 1,
        "group_id": 1,
        "amount": 100
    }
}
```

#### Get All Group Participants

`GET /api/groups/:group_id/participants`

Example return payload

```
{
    "data": [
        {
            "username": "bob",
            "id": 2,
            "group_id": 1,
            "amount": 100
        },
        {
            "username": "alice",
            "id": 1,
            "group_id": 1,
            "amount": 100
        }
    ]
}
```

#### Get Group Participant By ID

`GET /api/groups/:group_id/participants/:id`

Example return payload

```
{
    "data": {
        "username": "alice",
        "id": 1,
        "group_id": 1,
        "amount": 100
    }
}
```

#### Transfer Between Two Group Participants

`POST /api/groups/:group_id/transfer`

Request body

```
{
	"from": 2,
	"to": 1,
	"amount": 50
}
```

Example return payload

```
{
    "data": {
        "to_participant": {
            "username": "alice",
            "id": 1,
            "group_id": 1,
            "amount": 150
        },
        "from_participant": {
            "username": "bob",
            "id": 2,
            "group_id": 1,
            "amount": 50
        }
    }
}
```

#### Remove Participant From Group

`DELETE /api/groups/:group_id/participants/:id`

Example return payload

```
{
    "data": {
        "final_amount": 100
    }
}
```