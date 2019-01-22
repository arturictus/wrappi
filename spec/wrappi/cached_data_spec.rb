require 'spec_helper'

module Wrappi
  RSpec.describe CachedResponse do
    let(:data) do
      {
        raw_body: {foo: 'bar'}.to_json,
        code: 200,
        uri: "http://hello.com",
        success: true
      }
    end
    subject { described_class.new(data) }
    it "Behaves like Response" do
      expect(subject.called?).to eq false
      expect(subject.body.fetch("foo")).to eq "bar"
      expect(subject.success?).to eq true
      expect(subject.error?).to eq false
      expect(subject.raw_body).to eq data[:raw_body]
      expect(subject.uri).to eq data[:uri]
      expect(subject.status_code).to eq data[:code]
      expect(subject.call).to be subject
    end
  end
end
