require 'rails_helper'

RSpec.describe PokemonService do
  context '#info' do
    let(:pokemon_name) { 'mew' }
    let(:invalid_pokemon_name) { 'invalidpokemon'}

    it 'returns pokemon information' do
      # Requests to external APIs are automatically handled
      result = described_class.info(name: pokemon_name).success
      expect(result[:name]).to eq(pokemon_name)
      expect(result).to have_key(:description)
      expect(result).to have_key(:habitat)
      expect(result).to have_key(:is_legendary)
    end

    it 'returns NotFound failure for invalid pokemon' do
      # Requests to external APIs are automatically handled
      result = described_class.info(name: invalid_pokemon_name)
      expect(result.failure?).to be_truthy
      expect(result.failure.first).to eq(:not_found)
    end
  end
end
