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

require 'utils'
require 'request_factory'

require 'kanboard_resource'
require 'kanboard_column'
require 'kanboard_project'
require 'kanboard_task'
require 'kanboard_swimlane'
require 'kanboard_external_link'
require 'kanboard_user'
require 'kanboard_category'
require 'kanboard_tag'
require 'kanboard_mapper'

require 'redmine_issue'
require 'bugzilla'
require 'github_pr'

require 'profile'
require 'redmine_to_kanboard'
require 'task_runner'

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

  def self.prepare_bz_connection(connection_options)
    Bugzilla.set_options(connection_options)
  end

  def self.setup(profile)
    prepare_logger(profile.logger_level)
    prepare_kanboard_connection(profile.kanboard_options)
    prepare_bz_connection(profile.bugzilla_options)
  end
end

Clamp do
  def self.profile_options
    option ['-p', '--profile'], 'PROFILE_FILE', 'Profile file', required: true
    option ['-P', '--project-id'], 'PROJECT_ID', 'Project id'
  end

  def profile_object
    return @profile_object if @profile_object
    @profile_object = Profile.new(profile).tap do |profile|
      profile.project_id = project_id if project_id
    end
    Kansync.setup(@profile_object)
    @profile_object
  end

  subcommand "task", "Run one or more tasks" do
    option ['-t', '--task'], 'TASK_FILE', 'Task file'
    profile_options

    def execute
      TaskRunner.new(profile: profile_object, task_file: task).run_tasks
    end
  end

  subcommand 'redmine_to_kanboard', 'Clone Redmine ticket to Kanboard' do
    profile_options
    option ['-r', '--redmine-id'], 'REDMINE_ID', 'Redmine id', required: true
    option ['-t', '--tag'], 'TAG', 'tag', multivalued: true

    def execute
      task = RedmineToKanboard.new(profile: profile_object, redmine_id: redmine_id, tags: tag_list).run
      puts "Kanboard task #{task.id} created"
    end
  end
end

# TODO need a separate script to create cards
# TODO need a separate script to help with new iteration setup
# TODO scripts may need custom configuration per profile, e.g. email mapping
# TODO README with links to APIs, docker image, sql converting trick


