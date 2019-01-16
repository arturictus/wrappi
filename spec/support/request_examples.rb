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

  context 'redirects' do
    it 'by default follows redirects' do
      subject.path = '/dummy/redirect'
      expect(response.status).to eq 200
      expect(response.success?).to be true
      expect(response.body).to be_a Hash
      expect(response.body.dig('request', 'path')).to eq '/dummy/redirect'
    end
  end

  context 'with interpolated in url params' do
    let(:params) { { foo: :baz, id: 1 } }
    it 'sends expected url and params' do
      subject.path = '/dummy/:id'
      expect(response.status).to eq 200
      expect(response.success?).to be true
      expect(response.body.dig("params", "foo")).to eq 'baz'
      expect(response.body.dig('request', 'path')).to eq '/dummy/1'
      expect(response.body.dig('params', "id")).to eq "1"
    end
  end

  describe "arround request" do
    it 'When calling `call` block gets called' do
      var = 1
      klass = Class.new(endpoint) do
        around_request do |res, endpoint|
          var += 1
          res.call
        end
      end
      inst = klass.new(params)
      expect(inst.success?).to be true
      expect(var).to eq 2
      expect(inst.response).to be_a Wrappi::Response
      # expect(mock).to eq "STRING"
    end
    it 'When NOT calling `call` block does not get called' do
      var = 1
      klass = Class.new(endpoint) do
        around_request do |res, endpoint|
          var += 1
        end
      end
      inst = klass.new(params)
      expect(inst.success?).to be false
      expect(var).to eq 2
      expect(inst.response).to be_a Wrappi::Executer::UncalledRequest
      # expect(mock).to eq "STRING"
    end
  end
end
