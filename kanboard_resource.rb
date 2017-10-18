class KanboardResource
  attr_reader :params, :connection, :id

  def initialize(connection, params)
    @connection = connection
    @params = params
    @id = params['id']
  end

  def method_missing(name, *args, &block)
    if params.has_key?(name.to_s)
      params[name.to_s]
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    params.has_key?(name.to_s) || super
  end
end