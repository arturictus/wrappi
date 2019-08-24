shared_examples 'request_examples' do
  let(:params) { {} }
  subject { endpoint.new(params) }
  let(:response) { subject.response }

  it "VERB" do
    expect(response.body.dig("request", "method")).to eq verb.to_s.upcase
  end

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
    subject do
      klass = Class.new(endpoint) do
        path '/dummy/redirect'
      end
      klass.new(params)
    end
    it 'by default follows redirects' do
      expect(response.status).to eq 200
      expect(response.success?).to be true
      expect(response.body).to be_a Hash
      expect(response.body.dig('request', 'path')).to eq '/dummy/redirect'
    end
  end

  context 'with interpolated in url params' do
    let(:params) { { foo: :baz, id: 1 } }
    subject do
      klass = Class.new(endpoint) do
        path '/dummy/:id'
      end
      klass.new(params)
    end
    it 'sends expected url and params' do
      expect(response.status).to eq 200
      expect(response.success?).to be true
      expect(response.body.dig("params", "foo")).to eq 'baz'
      expect(response.body.dig('request', 'path')).to eq '/dummy/1'
      expect(response.body.dig('params', "id")).to eq "1"
    end
  end

  context 'basic_auth' do
    subject do
      klass = Class.new(endpoint) do
        path '/dummy_basic_auth'
      end
      klass.new(params)
    end
    it "valid authentication" do
      subject.basic_auth = { user: 'wrappi', pass: 'secret'}
      expect(response.status).to eq 200
      expect(response.success?).to be true
      expect(response.body.dig('request', 'path')).to eq '/dummy_basic_auth'
    end
    it "invalid authentication" do
      subject.basic_auth = { user: 'wrappi', pass: 'wrong'}
      expect(response.status).to eq 401
      expect(response.success?).to be false
    end
    it "no authentication" do
      expect(response.status).to eq 401
      expect(response.success?).to be false
    end
  end

  context "basic_auth from client" do
    subject do
      klass = Class.new(endpoint) do
        client DummyBasicAuth
        path '/dummy_basic_auth'
      end
      klass.new(params)
    end
    it "valid authentication" do
      expect(response.status).to eq 200
      expect(response.success?).to be true
      expect(response.body.dig('request', 'path')).to eq '/dummy_basic_auth'
    end
    it "invalid authentication" do
      subject.basic_auth = { user: 'wrappi', pass: 'wrong'}
      expect(response.status).to eq 401
      expect(response.success?).to be false
    end
  end

  describe 'call' do
    context 'unsuccessful response' do
      subject do
        klass = Class.new(endpoint) do
          path '/dummy_basic_auth'
        end
        klass.new(params)
      end
      it "returns false" do
        expect(subject.call).to be false 
      end
    end
    context 'successful response' do
      it 'returns instance' do
        expect(subject.call).to respond_to :success?
      end
    end
  end
  describe '::call' do
    context 'unsuccessful response' do
      subject do
        klass = Class.new(endpoint) do
                  path '/dummy_basic_auth'
                end
      end
      it "returns false" do
        expect(subject.call(params)).to be false 
      end
    end
    context 'successful response' do
      it 'returns instance' do
        expect(subject.class.call).to respond_to :success?
      end
    end
  end
  describe 'call!' do
    context 'unsuccessful response' do
      subject do
        klass = Class.new(endpoint) do
          path '/dummy_basic_auth'
        end
        klass.new(params)
      end
      it "returns false" do
        expect{ subject.call! }.to raise_error 
      end
    end
    context 'successful response' do
      it 'returns instance' do
        expect(subject.call).to respond_to :success?
      end
    end
  end
  describe '::call!' do
    context 'unsuccessful response' do
      subject do
        klass = Class.new(endpoint) do
                  path '/dummy_basic_auth'
                end
      end
      it "returns false" do
        expect {subject.call!(params) }.to raise_error 
      end
    end
    context 'successful response' do
      it 'returns instance' do
        expect(subject.class.call!).to respond_to :success?
      end
    end
  end

  describe "::body" do
    context 'unsuccessful response' do
      subject do
        klass = Class.new(endpoint) do
                  path '/dummy_basic_auth'
                end
      end
      it "returns body" do
        expect(subject.body(params)).to be_a String
        expect(subject.body(params)).to include "Access denied"
      end
    end
    context 'successful response' do
      it 'returns body' do
        expect(subject.class.body).to be_a Hash
      end
    end
  end

  describe "#on_success | #on_error" do
    it "executes on success block if is success response" do
      var = 0
      success = nil
      out = subject.on_success do |endpoint|
                      var = 1
                      success = endpoint.success?
                    end.on_error do |endpoint|
                      raise "You should not go this way"
                    end
      expect(var).to be 1
      expect(success).to be true
      expect(out).to respond_to :success? # is endpoint
    end
    context 'unsuccessful response' do
      subject do
        klass = Class.new(endpoint) do
                  path '/dummy_basic_auth'
                end
        klass.new
      end
      it "executes on_error block if is unsuccessful response" do
        var = 0
        success = nil
        out = subject.on_success do |endpoint|
                        raise "You should not go this way"
                      end.on_error do |endpoint|
                        var = -1
                        success = endpoint.success?
                      end
        expect(var).to be -1
        expect(success).to be false
        expect(out).to respond_to :success? # is endpoint
      end
    end
  end
end
