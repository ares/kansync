class RequestFactory
  def initialize(connection_options)
    @url = connection_options['url']
    @user = connection_options['user']
    @pw = connection_options['pw']
    @counter = 0
    @connection = conn = Faraday.new(:url => @url) do |faraday|
      # faraday.response :logger
      faraday.basic_auth(@user, @pw)
      faraday.adapter Faraday.default_adapter
    end
  end

  def request(method, params = nil)
    @counter += 1

    body = {
        'jsonrpc' => "2.0",
        'id' => @counter,
        'method' => method,
    }
    body.merge!('params' => params) unless params.nil?

    response = @connection.post do |req|
      req.url '/jsonrpc.php'
      req.headers['Content-Type'] = 'application/json'
      req.body = body.to_json
    end

    parsed_body = JSON.parse(response.body)
    if parsed_body['result']
      return parsed_body['result']
    else
      raise "Error processing the request #{method} (#{params.inspect}): #{parsed_body['error'].inspect}"
    end
  end
end