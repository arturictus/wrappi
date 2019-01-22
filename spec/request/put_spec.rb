require 'spec_helper'
describe "dummy PUT" do
  let(:endpoint) do
    klass = Class.new(Wrappi::Endpoint) do
      client Dummy
      verb :put
      path "/dummy"
    end
  end
  let(:verb) { :put }
  it_behaves_like 'request_examples'
end
