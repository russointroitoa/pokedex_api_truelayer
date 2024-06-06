require 'rails_helper'

# Note: Requests to external APIs are automatically handled by VCR and response is saved into spec/fixtures/vcr_cassettes. You can look at the configuration
# settings in rails_helper.rb

RSpec.describe PokemonService do
  context '#info' do
    let(:pokemon_name) { 'mew' }
    let(:invalid_pokemon_name) { 'invalidpokemon'}
    let(:description) { "So rare that it\nis still said to\nbe a mirage by\fmany experts. Only\na few people have\nseen it worldwide." }
    let(:yoda_description) { "To be a mirage by many experts,  so rare that it is still said.Only a few people have seen it worldwide." }
    let(:shakespeare_description) { "So rare yond 't is still did doth sayeth to beest a mirage by many experts. Only a few people hath't seen 't worldwide." }

    context 'when Pokemon exists' do
      it 'returns Pokemon information' do
        result = described_class.info(name: pokemon_name).success
        expect(result[:name]).to eq(pokemon_name)
        expect(result).to have_key(:description)
        expect(result).to have_key(:habitat)
        expect(result).to have_key(:is_legendary)
        expect(result.dig(:description)).to eq(description)
      end

      context 'translation is enable' do
        let(:translate_description) { true }
        let(:is_legendary) { false }
        let(:habitat) { 'rare' }
        
        # Modify part of the response stored into the VCR to explore additional test cases
        before(:each) do
          allow(Net::HTTP)
            .to receive(:get_response)
            .and_wrap_original do |method, *args|
              response = method.call(*args)
              response_body = JSON.parse(response.body, symbolize_names: true)
              response_body[:is_legendary] = is_legendary
              response_body[:habitat][:name] = habitat
              allow(response).to receive(:body).and_return(response_body.to_json)
              response
            end
        end

        context 'and is_legendary' do
          let(:is_legendary) { true }

          it 'returns Yoda-like translated description' do
            result = described_class.info(name: pokemon_name, translate_description:).success
            expect(result.dig(:description)).to eq(yoda_description)
          end
        end

        context 'and habitat is cave' do
          let(:habitat) { 'cave' }

          it 'returns Yoda-like translated description' do
            result = described_class.info(name: pokemon_name, translate_description:).success
            expect(result.dig(:description)).to eq(yoda_description)
          end
        end

        context 'not legendary and habitat is not cave' do
          it 'returns Shakespeare-like translated description' do
            result = described_class.info(name: pokemon_name, translate_description:).success
            expect(result.dig(:description)).to eq(shakespeare_description)
          end
        end

        context 'and Translation API fails' do
          before(:each) do
            allow(TranslationService).to receive(:call).and_return(Dry::Monads::Failure[:too_many_requests, "Too many requests"])
          end

          it 'returns standard description' do
            result = described_class.info(name: pokemon_name, translate_description:).success
            expect(result.dig(:description)).to eq(description)
          end
        end
      end
    end

    context 'when Pokemon does not exist' do
      it 'returns NotFound failure' do
        result = described_class.info(name: invalid_pokemon_name)
        expect(result.failure?).to be_truthy
        expect(result.failure.first).to eq(:not_found)
      end
    end
  end
end
