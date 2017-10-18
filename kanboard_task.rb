require 'kanboard_resource'

class KanboardTask < KanboardResource
  REDMINE_URL = 'projects.theforeman.org'
  GITHUB_URL = 'github.com'
  BUGZILLA_URL = 'bugzilla.redhat.com'

  def redmine_links?
    redmine_links.any?
  end

  def redmine_links
    external_links.select { |link| link.url.include?(REDMINE_URL)}
  end

  def github_links?
    github_link.any?
  end

  def github_links
    external_links.select { |link| link.url.include?(GITHUB_URL)}
  end

  def bugzilla_links?
    bugzilla_link.any?
  end

  def bugzilla_links
    external_links.select { |link| link.url.include?(BUGZILLA_URL)}
  end

  def links?(url)
    external_links.any? { |link| link.url == url }
  end

  def external_links
    @connection.request('getAllExternalTaskLinks', { 'task_id' => @id }).map do |attrs|
      KanboardExternalLink.new(@connection, attrs)
    end
  end

  def create_link(url, title = nil, type = 'weblink')
    params = [ @id.to_i, url, 'related', type, title ]
    @connection.request('createExternalTaskLink', params)
  end
end