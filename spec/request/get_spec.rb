require 'spec_helper'
describe "dummy GET" do
  let(:endpoint) do
    klass = Class.new(Wrappi::Endpoint) do
      client { Dummy.new }
      verb :get
      path "/dummy"
    end
    klass
  end
  it_behaves_like 'request_examples'
end
