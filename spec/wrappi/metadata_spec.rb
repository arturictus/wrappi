require 'spec_helper'
module Wrappi
  describe Metadata do
    class Config1
      def self.config
        Config.new(
          domain: 'http://api.github.com',
          path: -> { "users/#{params[:username]}" }
        )
      end

      def params
        { username: 'arturictus' }
      end
    end

    subject { Metadata.new(Config1.new) }

    it do
      expect(subject.url).to eq('http://api.github.com/users/arturictus')
    end
  end
end
