module Wrappi
  class Endpoint

    def fixture_name
      "#{self.class}#{fixture_params_key}.json"
    end

    def fixture_params_key
      return if processed_params.empty?
      d = Digest::MD5.hexdigest processed_params.to_json
      "-#{d}"
    end

    def fixture_content
      return {} unless success?
      {
        request: {
          method: verb.to_s,
          url: url,
          domain: domain,
          headers: headers,
          params: consummated_params,
          path: path_gen.path
        },
        response: {
          status: status,
          body: body
        }
      }
    end
  end

  module Testing
    def store_response(path, &block)
      endpoint = block.call
      raise "Not succesful call to #{endpoint.class}" unless endpoint.success?
      file_fullname = File.join(path, endpoint.fixture_name)
      return endpoint if File.exists?(file_fullname)
      File.open(file_fullname, "w") do |f|
        f.write(JSON.pretty_generate(endpoint.fixture_content))
      end
      endpoint
    end
  end
end