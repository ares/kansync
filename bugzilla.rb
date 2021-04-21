require 'rest-client'
require 'jsonrpc-client'

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

  def self.set_options(options, config)
    @options = options
    @config = config
  end

  def self.options
    @options
  end

  def self.config
    @config
  end

  def self.load(url)
    attrs = bz_query(id: url.gsub(/.*?(\d+)$/, '\1')).first
    self.new(attrs)
  end

  def self.search(filters = {})
    bz_query(filters).map { |bz| self.new(bz) }
  end

  def self.bz_query(filters = {})
    filters = filters.merge('api_key' => config.api_key) if config.api_key
    conn = Faraday.new(:url => config.url) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
      faraday.options.params_encoder = Faraday::FlatParamsEncoder
    end

    response = conn.get('/rest/bug', filters)
    JSON.parse(response.body)['bugs']
  end

  def self.get_issue(id)
    jsonrpc.invoke('Bug.get',[{api_key: config.api_key, ids: [id.to_i], include_fields: [:external_bugs, :summary, :comments],}])
  end

  # tracker url is the full url e.g. https://projects.engineering.redhat.com/browse/TFMRHCLOUD-165
  # tracker id is the short id as it appears in BZ. e.g. TFMRHCLOUD-165
  def self.put_tracker(id, tracker_url, tracker_id)
    return unless get_issue(id)['bugs'].first['external_bugs'].select { |link| link['ext_bz_bug_id'] == tracker_id }.empty?

    jsonrpc.invoke(
      'ExternalBugs.add_external_bug',
      [{
          api_key: config.api_key,
          bug_ids: [id.to_i],
          external_bugs: [
            {
              ext_bz_bug_url: tracker_url,
            },
          ],
        }]
    )
  end

  # known fields:
  #   cf_fixed_in: version,
  #   status: 'POST'
  def self.set_fields(id, fields)
    all_fields = fields.merge(
      api_key: config.api_key,
    )
    bz_api['bug']["#{id}"].put(all_fields)
  end

  def self.bugzilla_url(bz_id)
    "#{config.url}/show_bug.cgi?id=#{bz_id}"
  end

  private

  def self.bz_api
    RestClient::Resource.new(config.url + '/rest', params: {api_key: config.api_key})
  end

  def self.jsonrpc
    @jsonrpc ||= begin
      conn = Faraday.new(url: config.url + '/jsonrpc.cgi') do |faraday|
        faraday.response :logger, nil, { headers: true, bodies: true }
      end

      JsonRpcClient.new(config.url + '/jsonrpc.cgi', { connection: conn})
    end
  end

  # Need to monkey-patch valid_response? because it has a strict JSONRPC version check
  # https://github.com/fxposter/jsonrpc-client/blob/287f6d2418f9a67064ebff2417c281db2c3a17c8/lib/jsonrpc/client.rb#L194
  class JsonRpcClient < JSONRPC::Client
    private
    def valid_response?(data)
      return true
    end
  end

end
