redmine_statuses = {
    1 => "New",
    2 => "Assigned",
    9 => "Need more information",
    11 => "Needs design",
    7 => "Ready For Testing",
    8 => "Pending",
    4 => "Feedback",
    5 => "Closed",
    3 => "Resolved",
    10 => "Duplicate",
    6 => "Rejected",
}

# settings format
# map:
# mapping of kanboard columns - redmine issues, kanboard statuses order must be from left to right, if card has more than
# one redmine issue, we use the most left
#
# blockers:
# we ca prevent moving to specific column by setting a blocker based on tag or current column, e.g. don't move task to
# Review column if "needs_rebase" tag is set for the task, or don't move the task to Backlog if it's already in Work in progress
task_configuration = {
    'blockers' => {},
    'map' => {},
}.merge(task_configuration)
map = task_configuration['map']

project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"

  if task.redmine_links?
    logger.info "... found #{task.redmine_links.size} redmine links"

    kanboard_columns = task.redmine_links.map do |redmine_link|
      issue = RedmineIssue.new(redmine_link.url)
      map.find { |_, status_ids| status_ids.include?(issue.status_id) }
    end

    logger.debug "Found following redmine statuses for this task: #{kanboard_columns.join(', ')}"

    name = kanboard_columns.sort { |a,b| map.keys.index(a.first) <=> map.keys.index(b.first) }.first.try(:first)

    # name overrides based on task tags
    # TODO following override would be good to make configurable
    if name == 'Review' && (task.tags.include?('needs_rebase') || task.tags.include?('waiting_on_contributor'))
      logger.warn 'Overriding new state to Work in progress because of tag needs_rebase or waiting_on_contributor'
      name = 'Work in progress'
    end

    change_column = task.column_id != KanboardColumn.find_by_name(task.project_id, name).id
    blockers = task_configuration['blockers'][name] || {}
    blocked_by_tag = blockers['tag'].kind_of?(Array) && task.tags.any? { |tag| blockers['tag'].include?(tag) }
    blocked_by_state = blockers['column'].kind_of?(Array) && blockers['column'].any? do |blocked_column|
      task.column_id == KanboardColumn.find_by_name(task.project_id, blocked_column).id
    end
    blocked = blocked_by_tag || blocked_by_state

    if change_column && !blocked
      logger.warn "Setting the column #{name} for this task"
      task.move_to_column(name)
    end

    logger.debug "\n"
  end
end
