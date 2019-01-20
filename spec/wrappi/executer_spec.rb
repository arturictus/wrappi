require 'spec_helper'
module Wrappi
  class RandomTestError < StandardError; end

  describe Executer do
    let(:params) {{}}
    let(:endpoint) do
      Class.new(Endpoint) do
        client Dummy
        verb :get
        path "/dummy"
      end
    end
    let(:endpoint_inst) { endpoint.new(params) }
    subject { described_class.new(endpoint_inst) }

    describe "arround request" do
      it 'When calling `call` block gets called' do
        var = 1
        klass = Class.new(endpoint) do
          around_request do |res, endpoint|
            var += 1
            res.call
          end
        end
        inst = klass.new(params)
        expect(inst.success?).to be true
        expect(var).to eq 2
        expect(inst.response).to be_a Wrappi::Response
      end

      it 'When NOT calling `call` block does not get called' do
        var = 1
        klass = Class.new(endpoint) do
          around_request do |res, endpoint|
            var += 1
          end
        end
        inst = klass.new(params)
        expect(inst.success?).to be false
        expect(var).to eq 2
        expect(inst.response).to be_a Wrappi::UncalledRequest
      end
    end

    describe "retry" do
      describe "retry options" do
        it do
          var = 0
          klass = Class.new(endpoint) do
            retry_options do
              { tries: 4, on: RandomTestError }
            end
            retry_if do |res|
              res.error?
            end
            around_request do |res|
              var += 1
              raise RandomTestError if var == 2
              res.call if var == 4
            end
          end
          inst = klass.new(params)
          expect { inst.call }.not_to raise_error
          expect(inst.success?).to eq true
          expect(var).to eq 4
        end
      end
      it 'retries until has been called 3 times' do
        var = 0
        klass = Class.new(endpoint) do
          retry_if do |res|
            res.error?
          end
          around_request do |res|
            var += 1
            res.call if var == 3
          end
        end
        inst = klass.new(params)

        expect(inst.success?).to eq true
        expect(var).to eq 3
      end
    end
  end
end
