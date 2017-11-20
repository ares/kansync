project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"
  RedmineToKanboard.new(profile: profile, kanboard_task: task).run
end