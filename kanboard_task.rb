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
    github_links.any?
  end

  def github_links
    external_links.select { |link| link.url.include?(GITHUB_URL)}
  end

  def bugzilla_links?
    bugzilla_links.any?
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

  def move_to_column(name)
    column_id = KanboardColumn.find_by_name(connection, project_id, name).id
    @connection.request('moveTaskPosition', { 'project_id' => project_id, 'task_id' => @id, 'column_id' => column_id, 'position' => 1, 'swimlane_id' => swimlane_id})
  end

  def set_owner(name)
    user_id = KanboardUser.find_by_name(connection, name).id
    @connection.request('updateTask', { 'id' => @id, 'owner_id' => user_id })
  end

  def set_complexity(complexity)
    @connection.request('updateTask', { 'id' => @id, 'complexity' => complexity })
  end

  def tags
    @connection.request('getTaskTags', [@id]).map(&:last)
  end
end