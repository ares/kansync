class RedmineIssue
  attr_reader :url

  def initialize(url)
    @url = url

    response = Faraday.get(@url + '.json')
    @attrs = JSON.parse(response.body)['issue']
  end

  def bugzilla_id
    @attrs['custom_fields'].find { |f| f['name'] == 'Bugzilla link'}['value']
  end

  def bugzilla_link
    "https://bugzilla.redhat.com/show_bug.cgi?id=#{bugzilla_id}"
  end

  def status_id
    @attrs['status']['id'].to_i
  end

  def assigned_to
    @attrs.fetch('assigned_to', {})['name']
  end

  def updated_on
    @attrs['updated_on']
  end
end