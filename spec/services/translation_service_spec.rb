require 'rails_helper'

RSpec.describe TranslationService do
  context '#call' do
    let(:text) { "It was created by a scientist after years of horrific gene splicing and DNA engineering experiments." }

    context 'when valid request' do

      it 'returns yoda translation' do
        type = :yoda
        result = described_class.call(text: text, type: type)
        expect(result.success).to eq("Created by a scientist after years of horrific gene splicing and dna engineering experiments,  it was.")
      end

      it 'return shakespeare translation' do
        type = :shakespeare
        result = described_class.call(text: text, type: type)
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

    context 'when rate limited' do
      before(:each) do
        message = "Too Many Requests: Rate limit of 10 requests per hour exceeded. Please wait for 4 minutes and 19 seconds."
        stub_request(
          :post,
          "#{TranslationService::BASE_URL}/yoda"
        )
        .to_return(status: 429, body: {"error": message}.to_json, headers: {})
      end

      it 'return a Failure' do
        type = :yoda
        result = described_class.call(text: text, type: type)
        expect(result.failure.first).to eq(:too_many_requests)
      end
    end
  end
end
