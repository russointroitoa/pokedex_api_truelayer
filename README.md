# Pokedex API TrueLayer
This repository contains my implementation of a Pokedex REST API. The goal of this project is to provide:
1. Basic Pokemon information
2. Basic Pokemon information but with a fun translation of its description

To accomplish that, it should expose a couple of endpoints, namely `/pokemon/<pokemon_name>` and `/pokemon/translated/<pokemon_name>`, and rely on the (PokéAPI)[https://pokeapi.co/] to fetch data we are interested in.

## Requirements
- Ruby 3.2.0
- Docker

## Project Setup
Check your **Ruby version**:
```
ruby -v
```
If Ruby is not installed, use [rbenv](https://github.com/rbenv/rbenv) to manage multiple Ruby versions and install the required version by running:
```
rbenv install 3.2.0
```
In order to run the project locally, clone this repository:
```
git clone https://github.com/russointroitoa/pokedex_api_truelayer.git
```
and install the necessary dependencies:
```
bundle install
```
**Note**:
For the purpose of this project, an `.env` file containing the `RAILS_MASTER_KEY` is included; in a real scenario, this key must be kept secret, as well as the others `<environment>.key` files.

## Usage
To run the project, you can run the server via a **Rails command** or by building and running a **Docker container**.

### Docker
In order to run our server through Docker, a `docker-compose` file has been implemented and you can simply build and run the container via the following command:
```
docker compose up
```
After building and starting the container, you should be able to reach the server at `127.0.0.1:3000`.

### Rails
If the project has been installed locally, you can start the server by typing:
```
bundle exec rails s
```
This command expose the server on `127.0.0.1:3000`.

### Endpoints
Once the server is up and running, you can perform queries towards the following enpoints:
- `/pokemon/<pokemon_name>` in order to extract basic information about the requested Pokemon
- `/pokemon/translated/<pokemon_name>` in order to extract basic information about the requested Pokemon, supported by a _fun_ description translation

The second endpoint translates the Pokemon description based on the following rules:
- If the Pokemon's habitat is `cave` or it's a `legendary` Pokemon, then apply the **Yoda** translation.
- Otherwise apply the **Shakespeare** translation
- If you can't translate the Pokemon's description, then use the standard description

# Implementation Choices
### Rails
This project uses the well-known Ruby on Rails framework, which is based on a Model-View-Controller architecture. However, since the problem doesn't require any _View_ or _Model_ to access the database, the focus is mainly on the _Controller_ side. 

Moreover, in order to decouple the business logic from the actual controller, a set of individual components, called **Services**, has been added. These services are small Ruby classes that encapsulate part of the logic, following the so-called _Service Object_ pattern.

### Monads
The entire codebase strongly relies on **Monads**, which provide an elegant way of handling errors and chaining functions so that the code is much more understandable.

Resource:
- [dry-monads](https://dry-rb.org/gems/dry-monads/1.3/#:~:text=dry%2Dmonads%20is%20a%20set,if%20s%20and%20else%20s.)

### VCR
This library is used to record requests and responses from an external API. This tool is used during the _testing_ phase to avoid repetitive requests towards PokéAPI and FunTranslation. In particular, it register and store the first request to a specific endpoint, such that its response can be reused the next time.

Resource:
- https://github.com/vcr/vcr

### Github Actions
A simple workflow has been implemented to run tests with Github Actions.

# Future Improvements
The implementation of the task on this repo is intended as a simple demo to show a trivial REST API with two endpoints. Obviously, it's not a production-ready project. Some of the next topics to cover are:

- **Caching**: a cache-layer can improve substantially the performance of this API. In fact, there are around 1000 different Pokemons, each with a fixed name, habitat, description and legendary status. The rules on which the translation happened is fixed and not specified by the user by some kind of parameter. Therefore, there shouldn't be any problem regarding the memory and volatility of data. In addition, since the FunTranslation endpoint has a rate limit of 10 requests/hour, we should avoid duplicated requests by caching the results. 

- **Rate Limit System**: to limit the load and regulate the number of requested performed by each customer, a Rate Limit system should be implemented. 

- **Logging**: having a logging system helps monitoring the performance of the API and allows to detect possible issues faster.

- **CI**/**CD**: even though a simple workflow for testing has been proposed, in a production-environment we should implement multiple workflows to automate the release and deployment pipeline.  