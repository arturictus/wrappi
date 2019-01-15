require 'spec_helper'
describe "dummy GET" do
  let(:endpoint) do
    klass = Class.new(Wrappi::Endpoint) do
      client Dummy
      verb :get
      path "/dummy"
    end
  end
  let(:verb) { :get }
  it_behaves_like 'request_examples'
end
