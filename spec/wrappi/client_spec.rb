require 'spec_helper'
module Wrappi
  describe Client do
    class ServiceOne < Wrappi::Client
      setup do |config|
        config.domain = 'https://service-one.com'
        config.timeout = { write: 10 }
      end
    end
    class ServiceTwo < Wrappi::Client
      setup do |config|
        config.domain = 'https://service-two.com'
      end
    end
    it do
      expect(ServiceOne.domain).to eq 'https://service-one.com'
      expect(ServiceTwo.domain).to eq 'https://service-two.com'
      expect(ServiceTwo.timeout[:write]).to eq 9
      expect(ServiceOne.timeout[:write]).to eq 10
    end
  end
end
