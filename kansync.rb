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
require 'clamp'

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

module Kansync
  def self.logger
    @logger
  end

  def self.kanboard_connection
    @kanboard_connection
  end

  def self.prepare_logger(level = Logger::DEBUG)
    level ||= Logger::DEBUG
    return @logger if @logger
    @logger = Logger.new(STDOUT)
    @logger.level = level
  end

  def self.prepare_kanboard_connection(connection_options)
    return @kanboard_connection if @kanboard_connection
    @kanboard_connection = RequestFactory.new(connection_options)
  end

  def self.setup(logger_level: Logger::DEBUG, kanboard_options:)
    prepare_logger(logger_level)
    prepare_kanboard_connection(kanboard_options)
  end

  class TaskRunner
    WRONG_USAGE = 1
    attr_reader :profile

    def initialize(task_file:, profile_file:, project_id:)
      @task_file = task_file
      @profile_file = profile_file
      @project_id = project_id
      load_profile
      Kansync.setup(logger_level: profile['logger_level'], kanboard_options: profile['connection']['kanboard'])
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

    def load_profile
      @profile = YAML.load_file @profile_file
    end
  end
end

Clamp do
  subcommand "task", "Run one or more tasks" do
    option "--loud", :flag, "say it loud"
    option ['-t', '--task'], 'TASK_FILE', 'Task file'
    option ['-p', '--profile'], 'PROFILE_FILE', 'Profile file', required: true
    option ['-P', '--project-id'], 'PROJECT_ID', 'Project id'

    def execute
      Kansync::TaskRunner.new(task_file: task, profile_file: profile, project_id: project_id).run_tasks
    end
  end
end

# TODO need a separate script to create cards
# TODO need a separate script to help with new iteration setup
# TODO scripts may need custom configuration per profile, e.g. email mapping
# TODO README with links to APIs, docker image, sql converting trick


