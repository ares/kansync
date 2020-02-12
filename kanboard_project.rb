require 'kanboard_resource'

class KanboardProject < KanboardResource
  def current_swimlane
    @current_swimlane ||= KanboardSwimlane.new(connection.request('getActiveSwimlanes', { 'project_id' => @id})[0])
  end

  def previous_swimlane
    @previous_swimlane ||= KanboardSwimlane.new(connection.request('getActiveSwimlanes', { 'project_id' => @id})[2])
  end

  def current_tasks
    @current_tasks ||= search_tasks(%Q(status:open swimlane:"#{current_swimlane.name}"))
  end

  def current_filtered_tasks(filter: '')
    search_tasks(%Q(status:open swimlane:"#{current_swimlane.name}" #{filter}))
  end

  def current_done_tasks(done_column = 'Done', non_done_tags = ['needs_demo', 'needs_docs', 'needs_qa_notification'])
    search_tasks(%Q(status:open swimlane:"#{current_swimlane.name}" column:#{done_column})).select do |task|
      (task.tags & non_done_tags).empty?
    end
  end

  def search_tasks(query)
    connection.request('searchTasks', { 'project_id' => @id, 'query' => query }).map do |attrs|
      KanboardTask.new(attrs)
    end
  end
end
