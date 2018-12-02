require 'spec_helper'
describe "dummy GET" do
  let(:endpoint) do
    klass = Class.new(Wrappi::Endpoint) do
      client Local
      verb :get
      path "/dummy"
    end
  end
  let(:params) { {} }
  subject { endpoint.new(params) }
  context 'without params' do
    it do
      expect(subject.response.status).to eq 200
      expect(subject.response.success?).to be true
      expect(subject.response.body).to be_a Hash
    end
  end
  context 'with params' do
    let(:params) { { foo: :baz }}
    it do
      expect(subject.response.status).to eq 200
      expect(subject.response.success?).to be true
      expect(subject.response.body.fetch("foo")).to eq 'baz'
    end
  end
end
