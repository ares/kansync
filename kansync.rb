#!/usr/bin/env ruby
require 'faraday'
require 'base64'
require 'awesome_print'
require 'json'
require 'yaml'
require 'logger'
require 'active_support/core_ext/hash/conversions.rb'
require 'active_support/core_ext/numeric/time.rb'
require 'pry'
require 'optparse'

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'request_factory'

require 'kanboard_resource'
require 'kanboard_column'
require 'kanboard_project'
require 'kanboard_task'
require 'kanboard_swimlane'
require 'kanboard_external_link'
require 'kanboard_user'

require 'redmine_issue'
require 'bugzilla'

class Kansync
  WRONG_USAGE = 1
  attr_reader :profile

  def initialize
    @options = parse_args!

    load_profile
    prepare_logger
    prepare_kanboard_connection
  end

  def parse_args!
    options = {}
    parser = OptionParser.new do |opts|
      opts.banner = 'Usage: kansync.rb [options]'

      opts.on('-t', '--task=TASK_FILE', 'Task file') do |v|
        @task_file = v
      end

      opts.on('-p', '--profile=PROFILE_FILE', 'Profile file') do |v|
        @profile_file = v
      end

      opts.on('-P', '--project-id=PROJECT_ID', 'Project id') do |v|
        @project_id = v
      end
    end
    parser.parse!

    unless @profile_file
      puts 'Missing --profile option'
      puts parser.help
      exit(WRONG_USAGE)
    end
    options
  end

  def project_id
    @project_id ||= profile['kanboard']['project_id']
  end

  def run_tasks
    if @task_file
      tasks = [@task_file]
    else
      tasks = Dir.glob('tasks/*.rb')
      tasks = tasks.select { |t| profile['whitelist'].include?(task_name(t)) } if profile.has_key?('whitelist')
      tasks = tasks.reject { |t| profile['blacklist'].include?(task_name(t)) } if profile.has_key?('blacklist')
    end

    tasks.each do |task|
      project = KanboardProject.new('id' => project_id)
      task_configuration = profile.fetch('configuration', {}).fetch(task_name(task), {})

      logger.info "Starting task #{task}"
      instance_eval File.read(task), task, 1
      logger.info "Finished task #{task}\n"
    end
  end

  def self.logger
    @@logger
  end

  def logger
    self.class.logger
  end

  def self.kanboard_connection
    @@kanboard_connection
  end

  def kanboard_connection
    @@kanboard_connection
  end

  private

  def task_name(filename)
    File.basename(filename, '.rb')
  end

  def load_profile
    @profile = YAML.load_file @profile_file
  end

  def prepare_logger
    @@logger = Logger.new(STDOUT)
    @@logger.level = @profile['logger_level'] || Logger::DEBUG
  end

  def prepare_kanboard_connection
    @@kanboard_connection = RequestFactory.new(profile['connection']['kanboard'])
  end
end

Kansync.new.run_tasks

# TODO need a separate script to create cards
# TODO need a separate script to help with new iteration setup
# TODO scripts may need custom configuration per profile, e.g. email mapping
# TODO README with links to APIs, docker image, sql converting trick


