require 'rails_helper'

RSpec.describe PokemonController, type: :controller do
  describe "GET /show" do
    context 'when Pokemon exists' do
      let(:pokemon_name) { 'mew' }

      it 'returns success' do
        response = VCR.use_cassette('pokemon_request') do
          get :show, params: { name: pokemon_name }
        end
        expect(response).to have_http_status(:success)
      end
    end

    context 'when Pokemon doesn\'t exist' do
      let(:pokemon_name) { 'invalidpokemon' }

      it 'return NotFound error' do
        response = VCR.use_cassette('invalid_pokemon') do
          get :show, params: { name: pokemon_name }
        end
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
