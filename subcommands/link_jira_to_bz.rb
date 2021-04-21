class LinkJiraToBz
  attr_accessor :jira_id, :bz_id, :profile

  def initialize(profile:, jira_id:, bz_id:)
    @profile = profile
    @jira_id = jira_id
    @bz_id = bz_id
  end

  def run
    jira_issue_url = Jira.issue_url(jira_id)
    bz_url = Bugzilla.bugzilla_url(bz_id)
    jira_issue = Jira.issue(jira_id)

    description = jira_issue.summary.match(/(^\[BZ [^\]]+\] )?(?<rest>.*)/)[:rest]

    Jira.update_summary(jira_issue, "[BZ #{bz_id}] #{description}")
    Jira.add_remote_link(jira_issue, 'BZ', bz_url)

    Bugzilla.put_tracker(bz_id, jira_issue_url, jira_id)
  end
end
