require 'kanboard_resource'

class KanboardProject < KanboardResource
  def current_swimlane
    KanboardSwimlane.new(@connection, @connection.request('getActiveSwimlanes', { 'project_id' => @id})[0])
  end

  def current_tasks
    @connection.request('searchTasks', { 'project_id' => @id, 'query' => %Q(status:open swimlane:"#{current_swimlane.name}") }).map do |attrs|
      KanboardTask.new(connection, attrs)
    end
  end
end