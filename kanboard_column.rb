require 'kanboard_resource'

class KanboardColumn < KanboardResource
  def self.find_by_name(connection, project_id, name)
    new connection, connection.request('getColumns', [project_id]).find { |column| column['title'] == name }
  end
end