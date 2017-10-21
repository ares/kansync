# settings format
# map:
# mapping of redmine users to kanboard users, use full names
task_configuration = {
    'map' => {},
}.merge(task_configuration)
map = task_configuration['map']

project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"

  if task.redmine_links?
    logger.info "... found #{task.redmine_links.size} redmine links"

    issues = task.redmine_links.map do |redmine_link|
      RedmineIssue.new(redmine_link.url)
    end
    last_issue = issues.sort_by(&:updated_on).last
    next if last_issue.nil? || last_issue.assigned_to.nil?

    name = map.has_key?(last_issue.assigned_to) ? map[last_issue.assigned_to] : last_issue.assigned_to
    logger.debug "Picked following kanboard_name: #{name}"

    user = KanboardUser.find_by_name(task.connection, name)
    if !user.nil? && task.owner_id != user.id
      logger.info "Setting the owner #{name} for this task"
      task.set_owner(name)
    end

    logger.debug "\n"
  end
end