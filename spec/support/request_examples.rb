shared_examples 'request_examples' do
  let(:params) { {} }
  subject { endpoint.new(params) }
  let(:response) { subject.response }
  describe 'headers' do
    it 'sends then correctly'  do
      expect(response.body.dig("request", "content_type")).to eq 'application/json'
      expect(response.body.dig("request", "accept")).to eq 'application/json'
    end
  end
  context 'without params' do
    it 'success request' do
      expect(response.status).to eq 200
      expect(response.success?).to be true
      expect(response.body).to be_a Hash
    end
  end
  context 'with params' do
    let(:params) { { foo: :baz } }
    it 'sends expected params' do
      expect(response.status).to eq 200
      expect(response.success?).to be true
      expect(response.body.dig("params", "foo")).to eq 'baz'
    end
  end
end
