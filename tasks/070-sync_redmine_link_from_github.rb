# This task goes over each card and if it finds a github link, it tries to find respective redmine issue
# and add a link to it with label redmine
# you should consider setting up github credentials in your profile if you're hitting 5000 API requests limit
# from your IP
task_configuration = {}.merge(task_configuration)

github_username = @profile.github_options['username']
github_password = @profile.github_options['password']

project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"

  if task.github_links?
    task.github_links.each do |github_link|
      begin
        pr = GithubPr.new(github_link.url, github_username, github_password)
      rescue
        logger.error "invalid github URL #{github_link.url}, skipping"
        next
      end

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
