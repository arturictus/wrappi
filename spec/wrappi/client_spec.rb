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
      service_one = ServiceOne.new
      service_two = ServiceTwo.new
      expect(service_one.domain).to eq 'https://service-one.com'
      expect(service_two.domain).to eq 'https://service-two.com'
      expect(service_two.timeout[:write]).to eq 3
      expect(service_one.timeout[:write]).to eq 10
    end
  end
end
