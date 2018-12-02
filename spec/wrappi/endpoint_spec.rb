require 'spec_helper'
module Wrappi
  describe Endpoint do
    describe 'DSL' do
      let(:client) do
        klass = Class.new(Client) do
          setup do |c|
            c.domain = 'http://domain.com'
          end
        end
        klass

      end
      it 'literal methods' do
        klass = Class.new(described_class) do
          verb :get
          path "/users"
        end
        inst = klass.new()
        expect(inst.verb).to eq :get
        expect(inst.path).to eq '/users'
      end

      it 'blocks as configs' do
        klass = Class.new(described_class) do
          client Local
          verb :post
          path do
            "/users/#{some_id}"
          end

          def some_id
            10
          end
        end

        inst = klass.new()
        expect(inst.verb).to eq :post
        expect(inst.path).to eq '/users/10'
        # expect(inst.url.to_s).to eq 'http://localhost:9873/user/⁄s/10'
        expect(inst.response).to eq 'http://localhost:9873/users/10'

      end
      it 'default params' do
        def_params = { name: 'foo' }
        klass = Class.new(described_class) do
          client Github
          verb :get
          path "/users"
          default_params def_params
        end

        inst = klass.new()
        expect(inst.verb).to eq :get
        expect(inst.path).to eq '/users'
        expect(inst.url.to_s).to eq 'https://api.github.com/users'
        expect(inst.params).to eq def_params
      end
    end
  end
end
