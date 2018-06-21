class Profile
  attr_accessor :project_id, :kanboard_options, :logger_level, :task_configuration,
                :whitelist, :blacklist, :github_options,
                :backlog_swimlane_name

  def initialize(profile_file)
    @profile_file = profile_file
    load_profile
    initialize_vars
  end

  private

  def load_profile
    @data = YAML.load_file @profile_file
  end

  def initialize_vars
    @project_id = @data['kanboard']['project_id']
    @logger_level = @data['logger_level'] || Logger::DEBUG
    @kanboard_options = @data['connection']['kanboard']
    @task_configuration = @data.fetch('configuration', {})
    @backlog_swimlane_name = @task_configuration['backlog_swimlane_name']
    @whitelist = @data['whitelist']
    @blacklist = @data['blacklist']
    @github_options = @data['github']
  end
end

