require 'kanboard_resource'

class KanboardTag < KanboardResource
  def self.create(project_id, name)
    new(connection.request('createTag', [project_id, name]))
  end

  def self.find_by_name(project_id, name)
    all = get_all(project_id)
    all.find { |tag| tag.name.downcase == name.downcase }
  end

  def self.find_or_create(project_id, name)
    find_by_name(project_id, name) || create(project_id, name)
  end

  def self.get_all(project_id)
    connection.request('getTagsByProject', [project_id]).map do |data|
      new(data)
    end
  end
end
