require 'spec_helper'
module Wrappi
  describe Client do
    class ServiceOne < Wrappi::Client
      domain 'https://service-one.com'
      timeout = { write: 10 }
    end
    class ServiceTwo < Wrappi::Client
      domain 'https://service-two.com'
    end

    it do
      expect(ServiceOne.domain).to eq 'https://service-one.com'
      expect(ServiceTwo.domain).to eq 'https://service-two.com'
      expect(ServiceTwo.timeout[:write]).to eq 3
      expect(ServiceOne.timeout[:write]).to eq 10
    end
  end
end
