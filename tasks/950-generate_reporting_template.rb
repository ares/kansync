# default configuration
task_configuration = {
  'users' => {
    # 'User' => 15
  },
  'ignore_patterns' => [],
}.merge(task_configuration)


data_to_report = {}
unassigned = []
logger.info "starting to process data, this can take some time"
project.current_tasks.each do |task|
  logger.debug "processing #{task.title}"
  tags = task.tags.empty? ? '' : ' ' + task.tags.map {|t| "##{t}" }.join(' ')
  title = task.title + tags

  if task.assignee_name.nil?
    unassigned << title
    next
  end

  owner = task.assignee_name.split(' ').first
  data_to_report[owner] ||= { 'done' => [], 'iteration' => [], 'review' => []}

  case task.column_name
    when 'Done'
      data_to_report[owner]['done'] << title
    else
      data_to_report[owner]['iteration'] << title
  end

  if (match_data = title.match(/.* - \[(.*)\]/))
    reviewer = match_data[1]
    data_to_report[reviewer] ||= { 'done' => [], 'iteration' => [], 'review' => []}
    data_to_report[reviewer]['review'] << title
  end
end

logger.info "generating the template"

data_to_report.each do |owner, tasks|
  puts "==#{owner}=="
  puts "Iteration items:"
  tasks['iteration'].each do |item|
    puts "* #{item}"
  end

  puts "Done items:"
  tasks['done'].each do |item|
    puts "* #{item}"
  end

  puts "Review items:"
  tasks['review'].each do |item|
    puts "* #{item}"
  end

  puts "Other items:"
  puts "Plan:"
  puts ""
end
