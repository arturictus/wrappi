require 'spec_helper'
describe "dummy POST" do
  let(:endpoint) do
    klass = Class.new(Wrappi::Endpoint) do
      client Dummy
      verb :post
      path "/dummy"
    end
  end
  let(:verb) { :post }
  it_behaves_like 'request_examples'
end
