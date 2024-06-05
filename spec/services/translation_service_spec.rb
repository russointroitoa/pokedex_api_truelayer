require 'rails_helper'

RSpec.describe TranslationService do
  context '#call' do
    let(:text) { "It was created by a scientist after years of horrific gene splicing and DNA engineering experiments." }

    context 'when valid request' do

      it 'returns yoda translation' do
        type = :yoda
        result = VCR.use_cassette('yoda_valid_translation_request') do
          described_class.call(text: text, type: type)
        end
        expect(result.success).to eq("Created by a scientist after years of horrific gene splicing and dna engineering experiments,  it was.")
      end

      it 'return shakespeare translation' do
        type = :shakespeare
        result = VCR.use_cassette('shakespeare_valid_translation_request') do
          described_class.call(text: text, type: type)
        end
        expect(result.success).to eq("'t wast did create by a scientist after years of horrific gene splicing and dna engineering experiments.")
      end
    end

    context 'when invalid endpoint' do
      it 'return a Failure' do
        type = :eminem
        result = described_class.call(text: text, type: type)
        expect(result.failure).to be_a(ArgumentError)
      end
    end
  end
end
