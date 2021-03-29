# This task goes over each card and if it finds a github link, it syncs some PR tags or removes them
# you should consider setting up github credentials in your profile if you're hitting 5000 API requests limit
# from your IP
#
# settigns format:
# # tags map is used for mapping github label to kanboard tag and back
# tags_map:
#   Waiting on contributor: waiting_on_contributor
# # these tags will be added if corresponding github label is found
# sync_tags:
#   - waiting_on_contributor
#   - needs_demo
#   - needs_rebase
# # these tags will be removed if corresponding github label is no longer present
# auto_remove_tags:
#  - waiting_on_contributor
#   - needs_rebase
task_configuration = {}.merge(task_configuration)

def convert_to_kanboard_tags(tags, map)
  map.keys.each { |k| map[k.downcase] = map[k] }
  tags.map { |tag| map[tag.downcase] || tag.downcase }.compact
end

github_username = @profile.github_options['username']
github_password = @profile.github_options['password']

project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"

  pr = nil
  tags = task.github_links.map do |github_link|
    begin
      pr = GithubPr.new(github_link.url, github_username, github_password)
    rescue
      logger.error "invalid github URL #{github_link.url}, skipping"
      next
    end

    labels = []
    # closed PRs should be ignored entirely, we return no labels for them
    unless pr.closed?
      custom_labels = pr.needs_rebase? ? ['needs_rebase'] : []
      labels = custom_labels + pr.labels
    end
    labels
  end

  github_tags = convert_to_kanboard_tags(tags.flatten.compact.uniq, task_configuration['tags_map'])
  old_tags = task_tags = task.tags

  task_tags -= task_configuration['auto_remove_tags'].select { |t| !github_tags.include?(t) && task_tags.include?(t) }
  task_tags += github_tags.select { |t| task_configuration['sync_tags'].include?(t) }
  task_tags.uniq!

  if old_tags.sort != task_tags.sort
    logger.warn "Changing tags from #{task.tags.inspect} to #{task_tags.inspect}"
    task.set_tags(task_tags)
  end
end

