require 'rails_helper'

# Note: Requests to external APIs are automatically handled by VCR and response is saved into spec/fixtures/vcr_cassettes. You can look at the configuration
# settings in rails_helper.rb

RSpec.describe TranslationService do
  context '#call' do
    let(:text) { "So rare that it\nis still said to\nbe a mirage by\fmany experts. Only\na few people have\nseen it worldwide." }

    context 'when valid request' do

      it 'returns Yoda translation' do
        type = :yoda
        result = described_class.call(text: text, type: type)
        expect(result.success).to eq("To be a mirage by many experts,  so rare that it is still said.Only a few people have seen it worldwide.")
      end

      it 'return Shakespeare translation' do
        type = :shakespeare
        result = described_class.call(text: text, type: type)
        expect(result.success).to eq("So rare yond 't is still did doth sayeth to beest a mirage by many experts. Only a few people hath't seen 't worldwide.")
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
