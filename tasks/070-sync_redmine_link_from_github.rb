# This task goes over each card and if it finds a github link, it tries to find respective redmine issue
# and add a link to it with label redmine

# settigns format
# github:
#   username: email@example.com
#   password: mypassword

# username and password is required if you want to use authenticated API and avoid 5000 request limit per day
task_configuration = {
  'github' => {
    'username' => '',
    'password' => ''
  }
}.merge(task_configuration)

github_username = task_configuration['github']['username']
github_password = task_configuration['github']['password']

project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"

  if task.github_links?
    task.github_links.each do |github_link|
      # TODO move into github_pr.rb?
      data = github_link.url.match /\Ahttps:\/\/github.com\/(.*)\/(.*)\/pull\/(\d+)\Z/
      if data
        owner, repository, pr_number = data[1], data[2], data[3]
      else
        logger.error "Invalid github PR link #{github_link}, skipping"
        next
      end

      pr = GithubPr.new("/repos/#{owner}/#{repository}/pulls/#{pr_number}", github_username, github_password)
      if (issue = pr.redmine_issue)
        unless task.redmine_links.map(&:url).include?(issue.url)
          logger.warn "Adding redmine link #{issue.url}"
          task.create_redmine_links(issue.url)
        end
      else
        logger.debug "No redmine issue found for #{github_link.url}"
      end
    end
  end
end
