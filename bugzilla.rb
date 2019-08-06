class Bugzilla
  def initialize(attrs)
    @attrs = attrs
  end

  def id
    @attrs['id'].to_i
  end

  def summary
    @attrs['summary']
  end

  def pm_score
    @attrs['cf_pm_score'].to_i
  end

  def url
    "https://bugzilla.redhat.com/show_bug.cgi?id=#{id}"
  end

  def self.set_options(options)
    @options = options
  end

  def self.options
    @options
  end

  def self.load(url)
    attrs = bz_query(id: url.gsub(/.*?(\d+)$/, '\1')).first
    self.new(attrs)
  end

  def self.search(filters = {})
    bz_query(filters).map { |bz| self.new(bz) }
  end

  def self.bz_query(filters = {})
    filters = filters.merge('api_key' => options['api_key']) if options['api_key']
    conn = Faraday.new(:url => 'https://bugzilla.redhat.com') do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
      faraday.options.params_encoder = Faraday::FlatParamsEncoder
    end

    response = conn.get('/rest/bug', filters)
    JSON.parse(response.body)['bugs']
  end
end
