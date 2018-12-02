module Github
  class Users
    class Show < Wrappi::Endpoint
      client Github
      verb :get
      path do
        "/users/#{_params[:username]}"
      end
      # params {}
    end

  end
end
