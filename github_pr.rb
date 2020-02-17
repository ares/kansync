class GithubPr
  attr_reader :url
  GITHUB_API_FQDN = "https://api.github.com"

  # url expecterd in format https://github.com/theforeman/foreman/pull/123
  def initialize(url, username = '', password = '')
    data = url.match /\Ahttps:\/\/github.com\/(.*)\/(.*)\/pull\/(\d+)\Z/
    if data
      owner, repository, pr_number = data[1], data[2], data[3]
    else
      logger.error "Invalid github PR link #{url}, skipping"
      raise "invalid github URL"
    end
    url = "/repos/#{owner}/#{repository}/pulls/#{pr_number}"
    @attrs, @url = with_redirect_following(url, username, password) do |connection, url|
      response = connection.get(url)
      JSON.parse(response.body)
    end
  end

  def with_redirect_following(url, username, password)
    connection = Faraday.new(GITHUB_API_FQDN)
    connection.basic_auth(username, password) unless username.empty? && password.empty?
    loop do
      attrs = yield(connection, url)
      return attrs, url if attrs['message'] != 'Moved Permanently'
      url = attrs['url']
    end
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

  def mergeable?
    # Github returns null for mergable while it's calculating mergability, treat PRs as mergable until proven otherwise
    @attrs.fetch('mergeable') || @attrs.fetch('mergeable').nil?
  end

  def merged?
    @attrs.fetch('merged')
  end

  def needs_rebase?
    !mergeable? && !merged?
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
