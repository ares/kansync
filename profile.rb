class Profile
  attr_accessor :project_id, :kanboard_options, :logger_level, :task_configuration,
                :whitelist, :blacklist, :github_options, :bugzilla_options,
                :backlog_swimlane_name, :bugzilla_config, :jira_config

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
    @bugzilla_options = @data['bugzilla']
    @bugzilla_config = Bugzilla.new(@data['bugzilla'])
    @jira_config = Jira.new(@data['jira'])
  end

  class Bugzilla
    def initialize(yaml)
      @yaml = yaml
    end

    def api_key
      @yaml['api_key']
    end

    def username
      @yaml['user']
    end

    def password
      @yaml['password']
    end

    def url
      @yaml['url'] || 'https://bugzilla.redhat.com'
    end
  end

  class Jira
    def initialize(yaml)
      @yaml = yaml
    end

    def user
      @yaml['user']
    end

    def password
      @yaml['password']
    end

    def site
      @yaml['site'] || 'https://projects.engineering.redhat.com'
    end

    def board
      @yaml['board']
    end
  end
end
