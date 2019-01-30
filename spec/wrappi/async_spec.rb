require 'spec_helper'

module Wrappi
  class AsyncEndpoint < Wrappi::Endpoint
    client Dummy
    path "/dummy/:user_id"
    async_callback do |async_options|
      options[:async_options] = async_options
      if success?
        options[:success] = true
      else
        options[:error] = true
      end
    end
  end
  describe Async do
    context "existing endpoint" do
      let(:options) { {} }
      let(:async_options) { {foo: :bar} }
      subject { described_class.perform_later(AsyncEndpoint.to_s, {params: {user_id: 1}, options: options}, async_options) }
      it do
        subject
        expect(options.fetch(:success)).to be true
        expect(options.fetch(:async_options)).to eq async_options
      end
    end
  end
end
