#!/usr/bin/env ruby
require 'faraday'
require 'base64'
require 'awesome_print'
require 'json'
require 'yaml'
require 'logger'
require 'pry'

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'request_factory'

require 'kanboard_resource'
require 'kanboard_project'
require 'kanboard_task'
require 'kanboard_swimlane'
require 'kanboard_external_link'

require 'redmine_issue'

class Kansync
  WRONG_USAGE = 1
  attr_reader :profile, :logger, :kanboard_connection

  def initialize
    wrong_usage! if ARGV.size != 1

    load_profile
    prepare_logger
    prepare_kanboard_connection
  end

  def run_tasks
    tasks = Dir.glob('tasks/*.rb')
    tasks = tasks.select { |t| profile['whitelist'].include?(t) } if profile.has_key?('whitelist')

    tasks.each do |task|
      next if profile['blacklist'].include?(task)

      instance_eval File.read(task), task, 1
    end
  end

  private

  def load_profile
    @profile = YAML.load_file ARGV[0]
  end

  def prepare_logger
    @logger = Logger.new(STDOUT)
    @logger.level = @profile['logger_level'] || Logger::DEBUG
  end

  def prepare_kanboard_connection
    @kanboard_connection = RequestFactory.new(profile['connection']['kanboard'])
  end

  def wrong_usage!
    puts "Usage #{$0} PROFILE\n  e.g. #{$0} profile/default.yml"
    exit(WRONG_USAGE)
  end
end

Kansync.new.run_tasks

# TODO need a separate script to create cards
# TODO need a separate script to help with new iteration setup
# TODO scripts may need custom configuration per profile, e.g. email mapping
# TODO README with links to APIs, docker image, sql converting trick


