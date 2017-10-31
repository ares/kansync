# default configuration
task_configuration = {
  'users' => {
    # 'User' => 15
  },
  'color' => 'grey',
  'description' => 'Write here the BZ URLs that were triaged and final status:'
}.merge(task_configuration)

existing_triage_title = project.search_tasks('status:open swimlane:"' + project.current_swimlane.name + '" column:"Backlog"').map(&:title)

task_configuration['users'].each do |user, count|
  new_title = "Triage 15 BZs - #{user} (0/#{count})"
  if existing_triage_title.include?(new_title)
    logger.debug "Skipping #{user} triage card, it's already there"
  else
    logger.info "Creating new triage card with title: #{new_title}"
    description = task_configuration['description'].to_s + "\n\n"
    description += "* \n" * count
    KanboardTask.create('title' => new_title, 'project_id' => project.id, 'color_id' => task_configuration['color'], 'description' => description, 'tags' => ['bz_triage'])
  end

  logger.info "All new triage cards created"
end
