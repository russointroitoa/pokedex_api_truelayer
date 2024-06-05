require 'rails_helper'

RSpec.describe PokemonController, type: :controller do
  describe "GET /show" do
    context 'when Pokemon exists' do
      let(:pokemon_name) { 'mew' }

      it 'returns success' do
        get :show, params: { name: pokemon_name }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when Pokemon doesn\'t exist' do
      let(:pokemon_name) { 'invalidpokemon' }

      it 'return NotFound error' do
        get :show, params: { name: pokemon_name }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
