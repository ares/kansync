require_relative 'link_jira_to_bz'

class CloneBzToJira
  attr_accessor :bz_id, :project, :profile

  def initialize(profile:, bz_id:, project:)
    @profile = profile
    @bz_id = bz_id
    @project = project
  end

  def run(summary: nil)
    bz = Bugzilla.get_issue(bz_id)['bugs'].first
    summary ||= bz['summary']

    issue = Jira.create_issue(project: project, summary: summary)

    LinkJiraToBz.new(profile: profile, jira_id: issue.key, bz_id: bz_id).run
  end
end
