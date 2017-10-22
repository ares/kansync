require 'kanboard_resource'

class KanboardSwimlane < KanboardResource
  def self.create(project_id, params)
    id = connection.request('addSwimlane', [project_id, params['name'], params['description']])
    new connection.request('getSwimlane', [id])
  end

  def update(params)
    connection.request('updateSwimlane', [project_id, @id, params['name'], params['description']])
  end

  def self.find_by_name(project_id, name)
    new connection.request('getSwimlaneByName', [project_id, name])
  end

  def move_to_position(index)
    connection.request('changeSwimlanePosition', [project_id, @id, index])
  end
end