# frozen_string_literal: true

class PokemonController < ApplicationController
  def show
    permitted_params = params.permit(:name)
    pokemon_info = PokemonService.info(name: permitted_params[:name])
    case pokemon_info
    in Dry::Monads::Success(info)
      render json: info
    in Dry::Monads::Failure[:not_found, msg]
      render json: { error: msg }, status: 404
    in Dry::Monads::Failure(err)
      render status: :internal_server_error 
    end
  end
end
