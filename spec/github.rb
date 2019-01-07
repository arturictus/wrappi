require 'spec_helper'

describe Github do
  describe Github::User do
    subject { described_class.new(username: 'arturictus') }
    it do
      expect(subject.success?).to be true
    end
  end
end
