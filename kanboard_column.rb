require 'kanboard_resource'

class KanboardColumn < KanboardResource
  def self.find_by_name(project_id, name)
    new connection.request('getColumns', [project_id]).find { |column| column['title'] == name }
  end
end