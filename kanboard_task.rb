require 'kanboard_resource'

class KanboardTask < KanboardResource
  REDMINE_URL = 'projects.theforeman.org'
  GITHUB_URL = 'github.com'
  BUGZILLA_URL = 'bugzilla.redhat.com'

  def self.create(params)
    id = connection.request('createTask', params)
    new connection.request('getTask', 'task_id' => id)
  end

  def self.update(params)
    connection.request('updateTask', params)
  end

  def redmine_links?
    redmine_links.any?
  end

  def redmine_links
    external_links.select { |link| link.url.include?(REDMINE_URL)}
  end

  def redmine_issues
    redmine_links.map do |link|
      RedmineIssue.new(link.url)
    end
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

  def bugzillas
    bugzila_links.map { |link| Bugzilla.new(link) }
  end

  def sync_bugzilla_links
    return unless redmine_links?
    redmine_issues.map do |redmine_issue|
      next if redmine_issue.bugzilla_id.empty?
      next if links?(redmine_issue.bugzilla_link)
      create_link(redmine_issue.bugzilla_link, 'bugzilla')
    end
  end

  def create_redmine_links(*links)
    links.each do |link|
      create_link(link, 'redmine')
    end
  end

  def links?(url)
    external_links.any? { |link| link.url == url }
  end

  def external_links
    connection.request('getAllExternalTaskLinks', { 'task_id' => @id }).map do |attrs|
      KanboardExternalLink.new(attrs)
    end
  end

  def create_link(url, title = nil, type = 'weblink')
    params = [ @id.to_i, url, 'related', type, title ]
    connection.request('createExternalTaskLink', params)
  end

  def move_to_column(name)
    column_id = KanboardColumn.find_by_name(project_id, name).id
    connection.request('moveTaskPosition', { 'project_id' => project_id, 'task_id' => @id, 'column_id' => column_id, 'position' => 1, 'swimlane_id' => swimlane_id})
  end

  def move_to_swimlane(name)
    swimlane_id = KanboardSwimlane.find_by_name(project_id, name).id
    connection.request('moveTaskPosition', { 'project_id' => project_id, 'task_id' => @id, 'column_id' => column_id, 'position' => 1, 'swimlane_id' => swimlane_id})
  end

  def set_owner(name)
    user_id = KanboardUser.find_by_name(name).id
    connection.request('updateTask', { 'id' => @id, 'owner_id' => user_id })
  end

  def set_complexity(complexity)
    connection.request('updateTask', { 'id' => @id, 'complexity' => complexity })
  end

  def tags
    connection.request('getTaskTags', [@id]).map(&:last)
  end

  def set_tags(tags)
    params = [ project_id, @id, tags ]
    connection.request('setTaskTags', params)
  end

  def owner
    KanboardUser.find_by_id(self.owner_id)
  end
end
