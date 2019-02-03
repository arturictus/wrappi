require 'spec_helper'

module Wrappi
  class AsyncEndpoint < Wrappi::Endpoint
    client Dummy
    path "/dummy/:user_id"
    async_callback do |async_options|
      raise "async_callback_called"
    end
  end

  describe AsyncJob do
    let(:options) { {} }
    let(:async_options) { { set: { wait: 12 }, foo: :bar} }
    let(:params) { {user_id: 1} }
    let(:endpoint_args) { {params: params, options: options} }

    shared_examples "async flow" do
      it "async_callback gets called" do
        expect { subject }.to raise_error('async_callback_called')
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
        expect(described_class).to receive(:set).with(async_options[:set]).and_call_original
        expect(described_class).to receive(:perform_later).with(AsyncEndpoint.to_s, endpoint_args, async_options).and_call_original
      end
      subject do
        inst = AsyncEndpoint.new(params, options)
        inst.async(async_options)
      end
      include_examples 'async flow'
    end
    describe AsyncHandler do
      subject do
        inst = AsyncEndpoint.new(params, options)
        described_class.call(inst, async_options)
      end
      before do
        expect(AsyncJob).to receive(:set).with(async_options[:set]).and_call_original
        expect(AsyncJob).to receive(:perform_later).with(AsyncEndpoint.to_s, endpoint_args, async_options).and_call_original
      end
      include_examples 'async flow'
    end
  end
end
