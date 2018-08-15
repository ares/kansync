class RedmineToKanboard
  def initialize(profile:, redmine_id: nil, kanboard_task: nil, tags: nil)
    @profile = profile
    @redmine_id = redmine_id
    @kanboard_task = kanboard_task
    @tags = tags || []
  end

  def run
    load_redmine_issue
    return false unless @redmine_issue
    if @kanboard_task
      update
    else
      create
    end
  end

  def create
    create_kanboard_task
    sync_kanboard_task
    @kanboard_task
  end

  def update
    update_kanboard_task
    sync_kanboard_task
    puts "Kanboard task #{@kanboard_task.id} updated"
  end

  def sync_kanboard_task
    @kanboard_task.sync_bugzilla_links
    @kanboard_task.sync_github_links
  end

  private

  def load_redmine_issue
    if @redmine_id.nil? && @kanboard_task
      @redmine_issue = @kanboard_task.redmine_issues.first
    else
      @redmine_issue = RedmineIssue.new(@redmine_id)
    end
  end

  def create_kanboard_task
    @kanboard_task = KanboardTask.create('title' => task_title,
                                         'project_id' => project_id,
                                         'color_id' => color_id,
                                         'description' => task_description,
                                         'swimlane_id' => swimlane_id,
                                         'category_id' => category_id,
                                         'tags' => task_tags)
    @kanboard_task.create_redmine_links(@redmine_issue.url)
    @kanboard_task
  end

  def update_kanboard_task
    KanboardTask.update('id' => @kanboard_task.id, 'category_id' => category_id)
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
    "RM \##{@redmine_issue.id}: #{@redmine_issue.subject}"
  end

  def task_description
    @redmine_issue.description
  end

  def task_tags
    @tags
  end

  def category_id
    mapper.category.id if mapper.category
  end

  def mapper
    @kanboard_mapper ||= KanboardMapper.new(profile: @profile, redmine_issue: @redmine_issue)
  end
end
