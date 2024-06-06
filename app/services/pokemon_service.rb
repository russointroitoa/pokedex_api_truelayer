# frozen_string_literal: true

require 'net/http'

class PokemonService
  extend Dry::Monads[:result, :do]

  BASE_URL = 'https://pokeapi.co/api/v2'
  SPECIES_ENDPOINT = 'pokemon-species'
  DESCRIPTION_LANG = 'en'

  class << self
    #
    # Extract general information about a Pokemon, given its name
    #
    # @param [String] name Pokemon name
    #
    # @return [Success(Hash)/Failure] Return Pokemon information if the Pokemon exists, otherwise return Failure
    #
    def info(name:, translate_description: false)
      response = yield request(name:)
      result = yield fetch_info(response:)
      result = yield process_description(result:) if translate_description
      Success(result)
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
        uri = URI([BASE_URL, SPECIES_ENDPOINT, name.downcase].join('/'))
        response = Net::HTTP.get_response(uri)
        case response
        in Net::HTTPSuccess
          response = JSON.parse(response.body, symbolize_names: true)
          Success(response)
        in Net::HTTPNotFound
          Failure[:not_found, "Pokemon #{name} not found"]
        else
          Failure(JSON.parse(response.body))
        end
      rescue StandardError => e
        Failure(StandardError.new(e.message, error: e))
      end

      #
      # General info about a Pokemon: name, is_legendary, habitat and description
      #
      # @param [Hash] response Information about Pokemon species
      #
      # @return [Hash] General info about the requested Pokemon
      #
      def fetch_info(response:)
        result = response.slice(:name, :is_legendary, :habitat, :flavor_text_entries)
        description = result
          .dig(:flavor_text_entries)
          .select { |d| d.dig(:language, :name) == DESCRIPTION_LANG }
          .first
        result[:description] = description.present? ? description.dig(:flavor_text) : ''
        result[:habitat] = result.dig(:habitat, :name)
        Success(result.except(:flavor_text_entries))
      end

      #
      # Translate description according to the following rules:
      # - if Pokemon habitat is 'cave' or Pokemon is legendary, then use 'yoda' translate
      # - otherwise use 'shakespeare' translation
      # - In case of issues in translating the description, use the standard description
      #
      # @param [Hash] result Pokemon information
      #
      # @return [Success(Hash)/Failure] Pokemon information with translated description
      #
      def process_description(result:)
        type = (result.dig(:habitat) == 'cave' || result.dig(:is_legendary)) ? :yoda : :shakespeare
        translated_description =
          case TranslationService.call(text: result[:description], type: type)
          in Success(description)
            description
          in Failure
            result[:description]
          end
        result[:description] = translated_description
        Success(result)
      end
  end
end