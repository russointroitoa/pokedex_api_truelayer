# frozen_string_literal: true

class PokemonController < ApplicationController
  def show
    permitted_params = params.permit(:name)
    perform(endpoint: :show, params: permitted_params)
  end

  def translated
    permitted_params = params.permit(:name)
    perform(endpoint: :translated, params: permitted_params)
  end

  private
    def perform(endpoint:, params:)
      translate_description = endpoint == :translated ? true : false
      pokemon_info = PokemonService.info(name: params[:name], translate_description:)
      case pokemon_info
      in Dry::Monads::Success(info)
        render json: info
      in Dry::Monads::Failure[:not_found, msg]
        render json: { error: msg }, status: 404
      in Dry::Monads::Failure[:too_many_requests, msg]
        render json: { error: msg }, status: 429
      in Dry::Monads::Failure(err)
        render json: { error: err }, status: :internal_server_error 
      end
    end
end
