class Bugzilla
  attr_reader :url

  def initialize(url)
    @url = url

    response = Faraday.get(@url + '&ctype=xml')
    @attrs = Hash.from_xml(response.body)['bugzilla']['bug']
  end

  def pm_score
    @attrs['cf_pm_score'].to_i
  end
end