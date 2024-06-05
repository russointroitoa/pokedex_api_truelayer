# frozen_string_literal: true

require 'net/http'

class PokemonService
  extend Dry::Monads[:result, :do]

  BASE_URL = 'https://pokeapi.co/api/v2'
  SPECIES_ENDPOINT = 'pokemon-species'
  DESCRIPTION_LANG = 'en'

  class << self
    def info(name:)
      response = yield request(name:)
      fetch_info(response:)
    end
    
    private
      #
      # Request toward PokéAPI endpoint to fetch Pokemon data 
      #
      # @param [String] name Pokemon name
      #
      # @return [Success(Hash)/Failure] If requested Pokemon exists, return Success. Otherwise return Failure 
      #
      def request(name:)
        uri = URI([BASE_URL, SPECIES_ENDPOINT, name].join('/'))
        response = Net::HTTP.get_response(uri)
        case response
        in Net::HTTPSuccess
          response = JSON.parse(response.body, symbolize_names: true)
          Success(response)
        in Net::HTTPNotFound
          Failure[:not_found, "Pokemon #{name} not found"]
        else
          Failure(response.body)
        end
      end

      #
      # General info about a Pokemon: ID, name, is_legendary, habitat and description
      #
      # @param [Hash] response Information about Pokemon species
      #
      # @return [Hash] General info about the requested Pokemon
      #
      def fetch_info(response:)
        result = response.slice(:id, :name, :is_legendary, :habitat, :flavor_text_entries)
        description = result
          .dig(:flavor_text_entries)
          .select { |d| d.dig(:language, :name) == DESCRIPTION_LANG }
          .first
        result[:description] = description.present? ? description.dig(:flavor_text) : ''
        result[:habitat] = result.dig(:habitat, :name)
        Success(result.except(:flavor_text_entries))
      end
  end
end