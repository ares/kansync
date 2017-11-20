class KanboardResource
  attr_reader :params, :id

  def initialize(params)
    @params = params
    @id = params['id']
  end

  def self.connection
    @connection = Kansync.kanboard_connection
  end

  def connection
    self.class.connection
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