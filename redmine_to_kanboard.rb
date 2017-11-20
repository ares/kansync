class RedmineToKanboard
  def initialize(profile:, redmine_id:)
    @profile = profile
    @redmine_id = redmine_id
  end

  def run
    load_redmine_issue
    create_kanboard_task
    puts "Kanboard task #{@kanboard_task.id} created"
  end

  private

  def load_redmine_issue
    @redmine_issue = RedmineIssue.new(@redmine_id)
  end

  def create_kanboard_task
    @kanboard_task = KanboardTask.create('title' => task_title,
                                         'project_id' => project_id,
                                         'color_id' => color_id,
                                         'description' => task_description,
                                         'swimlane_id' => swimlane_id,
                                         'tags' => task_tags)
  end

  def swimlane_id
    unless @swimlane
      swimlane_name = @profile.backlog_swimlane_name
      raise 'backlog_swimlane_name not configured' unless swimlane_name
      @swimlane = KanboardSwimlane.find_by_name(project_id, swimlane_name)
      raise "Swimlane #{swimlane_name} not found in project #{project_id}" unless @swimlane
    end
    return @swimlane.id
  end

  def project_id
    @profile.project_id
  end

  def color_id
    @profile.task_configuration['color']
  end

  def task_title
    @redmine_issue.subject
  end

  def task_description
    @redmine_issue.description
  end

  def task_tags
    []
  end
end
