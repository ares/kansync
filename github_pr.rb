class GithubPr
  attr_reader :url
  GITHUB_API_FQDN = "https://api.github.com"

  def initialize(url, username = '', password = '')
    @url = url.chomp('/')
    connection = Faraday.new(GITHUB_API_FQDN)
    connection.basic_auth(username, password) unless username.empty? && password.empty?
    response = connection.get(url)
    @attrs = JSON.parse(response.body)
  end

  def id
    @attrs.fetch('number')
  end

  def title
    @attrs.fetch('title')
  end

  def redmine_issue
    issue = title.match(/#(\d+)/).try(:[], 1)
    if issue
      RedmineIssue.new(issue)
    else
      nil
    end
  end

  def user
    @attrs.fetch('user').fetch('login')
  end

  def repository
    base_attr('repo').fetch('name')
  end

  def owner
    base_attr('repo').fetch('owner', {})['login']
  end

  def state
    @attrs.fetch('state')
  end

  def opened?
    state == 'open'
  end

  def closed?
    state == 'closed'
  end

  def labels
    @attrs.fetch('labels', []).map { |label| label['name'] }
  end

  private

  def head_attr(attr)
    @attrs.fetch('head', {})[attr]
  end

  def base_attr(attr)
    @attrs.fetch('base', {})[attr]
  end
end
