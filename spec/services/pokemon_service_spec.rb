require 'rails_helper'

RSpec.describe PokemonService do
  context '#info' do
    let(:pokemon_name) { 'mew' }
    let(:invalid_pokemon_name) { 'invalidpokemon'}

    context 'when Pokemon exists' do
      it 'returns Pokemon information' do
        # Requests to external APIs are automatically handled
        result = described_class.info(name: pokemon_name).success
        expect(result[:name]).to eq(pokemon_name)
        expect(result).to have_key(:description)
        expect(result).to have_key(:habitat)
        expect(result).to have_key(:is_legendary)
        expect(result.dig(:description)).to eq(
          "So rare that it\nis still said to\nbe a mirage by\fmany experts. Only\na few people have\nseen it worldwide."
        )
      end

      context 'translation is enabled and is_legendary' do
        it 'returns Yoda-like translated description' do
          result = described_class.info(name: pokemon_name, translate_description: true).success
          expect(result.dig(:description)).to eq(
            "So rare yond 't is still did doth sayeth to beest a mirage by many experts. Only a few people hath't seen 't worldwide."
          )
        end
      end
    end

    it 'returns NotFound failure for invalid pokemon' do
      # Requests to external APIs are automatically handled
      result = described_class.info(name: invalid_pokemon_name)
      expect(result.failure?).to be_truthy
      expect(result.failure.first).to eq(:not_found)
    end
  end
end
