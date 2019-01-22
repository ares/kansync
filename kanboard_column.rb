require 'kanboard_resource'

class KanboardColumn < KanboardResource
  def self.find_by_name(project_id, name)
#    result = connection.request('getColumns', [project_id]).find { |column| column['title'] == name }
#    binding.pry if result.nil?
    new connection.request('getColumns', [project_id]).find { |column| column['title'] == name }
  end
end
