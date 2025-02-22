# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Rails Docker Project

## Prerequisites
- Docker
- Docker Compose

## Setup Instructions

1. Clone the repository
```bash
git clone https://github.com/YoshikazuNakahara/rails-docker.git
cd rails-docker
```

2. Build and start the containers
```bash
docker-compose build
docker-compose up
```

3. Setup the database
```bash
docker-compose run web rails db:create
docker-compose run web rails db:migrate
```

## Accessing the Application
- Web Application: http://localhost:3000
- Database: localhost:5432

## Stopping the Application
```bash
docker-compose down
```

## Development
- All Rails commands should be run via `docker-compose run web`
- Example: `docker-compose run web rails generate model User`
