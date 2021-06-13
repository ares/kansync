require 'jira-ruby'

class Jira
  def self.set_config(config)
    @config = config
  end

  def self.issue(id)
    api.Issue.find(id)
  end

  def self.issue_url(issue_id)
    "#{config.site}/browse/#{issue_id}"
  end

  def self.update_summary(issue, summary)
    issue.save({'fields' => { 'summary' => summary}})
  end

  def self.add_remote_link(issue, label, url)
    return if issue.remotelink.all.find { |link| link.attrs.dig('object', 'title') }
    link = issue.remotelink.build

    link.save(
      object: {
        url: url,
        title: label
      }
    )
  end

  def self.create_issue(summary:, project:, fields: {})
    options = fields.merge(
      'summary' => summary,
      'project' => {
        'key' => project
      },
      'issuetype' => {
        'id' => '3',
      }
    )

    issue = api.Issue.build
    issue.save(fields: options)
    issue.fetch
    issue
  end

  def self.active_sprints
    api.Agile.get_sprints(config.board, state: 'active')
  end

  def self.find_sprint(id)
    api.Sprint.find(id)
  end

  private

  def self.api
    @client ||= JIRA::Client.new({
      username: config.user,
      password: config.password,
      site: config.site,
      context_path: '',
      auth_type: :basic,
      ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
    })
  end

  def self.config
    @config
  end

  def self.project(id)
    api.Project.find(id)
  end
end
