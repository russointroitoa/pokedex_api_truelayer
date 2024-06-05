# frozen_string_literal: true

require 'net/http'

class TranslationService
  extend Dry::Monads[:result, :do]

  BASE_URL = 'https://api.funtranslations.com/translate'
  AVAILABLE_ENDPOINTS = [:shakespeare, :yoda]

  class << self
    #
    # Translate a given text according to Yoda or Shakespeare translation
    #
    # @param [String] text Text to be translated
    # @param [Symbol] type Type of translation
    #
    # @return [Success(String)/Failure] Translated text
    #
    def call(text:, type:)
      yield check_type(type:)
      response = yield request(text:, type:)
      parse_response(response)
    end

    private
      #
      # Check if the type of translation is permitted
      #
      # @param [Symbol] type Type of translation: available values [:yoda, :shakespeare]
      #
      # @return [Success/Failure] Return Success if the type is available, Failure
      #
      def check_type(type:)
        if !AVAILABLE_ENDPOINTS.include?(type)
          return Failure(ArgumentError.new("Translation type #{type} not available"))
        end
        Success(true)
      end
      
      #
      # Perform an HTTP request to funtranslation.com to translate a given text
      #
      # @param [String] text Text to be translated
      # @param [Symbol] type Type of translation
      #
      # @return [Success(String)/Failure] Return the translated text
      #
      def request(text:, type:)
        uri = URI([BASE_URL, type.to_s].join('/'))
        # Set HTTPS
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        # Perform request
        http_request = Net::HTTP::Post.new(uri)
        http_request["Content-Type"] = 'application/json'
        http_request.body = { text: text }.to_json
        response = http.request(http_request)

        case response
        in Net::HTTPSuccess
          Success(JSON.parse(response.body, symbolize_names: true))
        in Net::HTTPTooManyRequests
          Failure[:too_many_requests, JSON.parse(response.body)["error"]]
        else
          Failure(JSON.parse(response.body))
        end
      rescue StandardError => e
        Failure(StandardError.new(e.message, error: e))
      end

      #
      # Process the HTTP response by fetching only the relevant content
      #
      # @param [Hash] response HTTP Response
      #
      # @return [<Type>] <description>
      #
      def parse_response(response)
        return Success(response.dig(:contents, :translated)) if response.dig(:success, :total).positive?

        Success(response.dig(:contents, :text))
      end
  end
end