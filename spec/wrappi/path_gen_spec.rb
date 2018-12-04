require 'spec_helper'
module Wrappi
  describe PathGen do
    context 'with one param' do
      it 'adds param to the path and removes it from the params' do
        inst = described_class.new('/users/:user_id', user_id: 1, foo: 'baz')
        expect(inst.compiled_path).to eq '/users/1'
        expect(inst.processed_params).to eq({"foo"=>"baz"})
      end
    end
    context 'without param in the path' do
      it 'does nothing' do
        inst = described_class.new('/users', user_id: 1, foo: 'baz')
        expect(inst.compiled_path).to eq '/users'
        expect(inst.processed_params).to eq({"foo"=>"baz", "user_id"=>1})
      end
    end
    context 'multiple params' do
      it 'removes all params to the input_params' do
        inst = described_class.new('/users/:user_id/comments/:foo', user_id: 1, foo: 'baz')
        expect(inst.compiled_path).to eq '/users/1/comments/baz'
        expect(inst.processed_params).to eq({})
      end
      it 'works with string keys' do
        inst = described_class.new('/users/:user_id/comments/:foo', "user_id" => 1, "foo" => 'baz')
        expect(inst.compiled_path).to eq '/users/1/comments/baz'
        expect(inst.processed_params).to eq({})
      end
    end
    context 'when missing param' do
      it 'raises error' do
        inst = described_class.new('/users/:user_id/comments/:foo', user_id: 1)
        expect {
          inst.compiled_path
        }.to raise_error(PathGen::MissingParamError)
      end
    end

  end
end
