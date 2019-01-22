require 'spec_helper'
describe "dummy DELETE" do
  let(:endpoint) do
    klass = Class.new(Wrappi::Endpoint) do
      client Dummy
      verb :delete
      path "/dummy"
    end
  end
  let(:verb) { :delete }
  it_behaves_like 'request_examples'
end
