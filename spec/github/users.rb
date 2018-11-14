module Github
  class Users
    class Show < Wrappi::Endpoint
      client Github
      verb :get
      path "/users/#{_params[:username]}"
      # params {}
    end

  end
end
