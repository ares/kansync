class TaskRunner
  WRONG_USAGE = 1
  attr_reader :profile

  def initialize(profile:, task_file:)
    @task_file = task_file
    @profile = profile
  end

  def project_id
    @profile.project_id
  end

  def run_tasks
    if @task_file
      tasks = [@task_file]
    else
      tasks = Dir.glob('tasks/*.rb')
      logger.debug "Available tasks: #{tasks.join(', ')}"
      tasks = tasks.select { |t| profile.whitelist.include?(task_name(t)) } if profile.whitelist
      logger.debug "Remaining tasks after whitelist applied: #{tasks.join(', ')}"
      tasks = tasks.reject { |t| profile.blacklist.include?(task_name(t)) } if profile.blacklist
      logger.debug "Remaining tasks after blacklist applied: #{tasks.join(', ')}"
      tasks.sort!
    end

    project = KanboardProject.new('id' => project_id)
    tasks.each do |task|
      task_configuration = profile.task_configuration.fetch(task_name(task), {})

      logger.info "Starting task #{task}"
      start = Time.now
      instance_eval File.read(task), task, 1
      finish = Time.now
      logger.info "Finished task #{task} in #{finish-start} seconds\n"
    end
  end

  def kanboard_connection
    Kansync.kanboard_connection
  end

  def logger
    Kansync.logger
  end

  private

  def task_name(filename)
    File.basename(filename, '.rb')
  end
end
