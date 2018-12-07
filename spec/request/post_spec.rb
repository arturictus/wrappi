require 'spec_helper'
describe "dummy POST" do
  let(:endpoint) do
    klass = Class.new(Wrappi::Endpoint) do
      client { Dummy.new }
      verb :post
      path "/dummy"
    end
  end
  it_behaves_like 'request_examples'
end
