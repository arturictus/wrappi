module Github
  class Users
    class Show < Wrappi::Endpoint
      def client() Github; end
      def verb() :get; end
      def path() "/users/#{_params[:username]}"; end
      def params() {}; end
    end

  end
end
