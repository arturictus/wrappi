class Users < Wrappi::Endpoint
  def self.config
    {
      url: nil,
      domain: '',
      headers: '',
      verb: :get,
      added_headers: []
    }
  end

 
end
