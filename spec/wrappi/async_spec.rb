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
    let(:options) { {} }
    let(:async_options) { {foo: :bar} }
    let(:params) { {user_id: 1} }
    let(:endpoint_args) { {params: params, options: options} }

    shared_examples "async flow" do
      it "Job gets called with options" do
        subject
        expect(options.fetch(:success)).to be true
        expect(options.fetch(:async_options)).to eq async_options
      end
    end

    context "existing endpoint" do
      subject { described_class.perform_later(AsyncEndpoint.to_s, endpoint_args, async_options) }
      include_examples 'async flow'
    end
    context "When endpoint const does not exists" do
      subject { described_class.perform_later("UnknowEndpoint", endpoint_args, async_options) }
      it do
        expect{ subject }.not_to raise_error 
      end
    end
    describe "endpoint #async(opts = {})" do
      before do
        expect(described_class).to receive(:perform_later).with(AsyncEndpoint.to_s, endpoint_args, async_options).and_call_original
      end
      subject do
        inst = AsyncEndpoint.new(params, options)
        inst.async(async_options)
      end
      include_examples 'async flow'
    end
  end
end
