# settings format
# map:
# mapping of kanboard tags to kanboard columns
#
# blockers:
# we ca prevent moving to specific column by setting a blocker based on tag or current column, e.g. don't move task to
# Review column if "needs_rebase" tag is set for the task, or don't move the task to Backlog if it's already in Work in progress
task_configuration = {
    'map' => {},
}.merge(task_configuration)
map = task_configuration['map']

project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"

  next if task.tags.empty?

  logger.info "... found #{task.tags.size} tags"

  kanboard_columns = task.tags.map do |tag|
    found = map[tag]
    logger.debug "Couldn't find column name for #{tag}" if found.nil?
    found
  end
  kanboard_columns.compact!

  next if kanboard_columns.empty?

  logger.debug "Found following columns for this task: #{kanboard_columns.join(', ')}"
  name = kanboard_columns.first

  change_column = task.column_id != KanboardColumn.find_by_name(task.project_id, name).id

  if change_column
    logger.warn "Setting the column #{name} for this task"
    task.move_to_column(name)
  end

  logger.debug "\n"
end
