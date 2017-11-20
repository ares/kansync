require 'kanboard_resource'

class KanboardCategory < KanboardResource
  def self.create(project_id, name)
    id = connection.request('createCategory', project_id: project_id, name: name)
    new connection.request('getCategory', [id])
  end

  def self.find_by_name(project_id, name)
    all = get_all(project_id)
    all.find { |category| category.name.downcase == name.downcase }
  end

  def self.find_or_create(project_id, name)
    find_by_name(project_id, name) || create(project_id, name)
  end

  def self.get_all(project_id)
    connection.request('getAllCategories', project_id: project_id).map do |data|
      new(data)
    end
  end

  def move_to_position(index)
    connection.request('changeSwimlanePosition', [project_id, @id, index])
  end
end
