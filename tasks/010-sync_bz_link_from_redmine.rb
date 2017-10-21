project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"

  if task.redmine_links?
    logger.info "... found #{task.redmine_links.size} redmine links"

    task.redmine_links.each do |redmine_link|
      issue = RedmineIssue.new(redmine_link.url)
      if !issue.bugzilla_id.empty?
        if !task.links?(issue.bugzilla_link)
          logger.debug "...... redmine issue is linked to #{issue.bugzilla_link}, syncing to kanboard task"
          if task.create_link(issue.bugzilla_link, 'Redmine')
            logger.debug '... done'
          else
            logger.error "... error saving the new task link for #{task.title}"
          end
        else
          logger.debug "...... already has a link to #{issue.bugzilla_link}, skipping"
        end
      else
        logger.debug "... no bz link in redmine found, skipping"
      end
    end

    logger.debug "\n"
  end
end