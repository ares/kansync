require 'kanboard_resource'

class KanboardUser < KanboardResource
  def self.find_by_name( name)
    user = connection.request('getAllUsers').find { |u| u['name'] == name }
    if user.nil?
      Kansync.logger.error "Kanboard user with name #{name} not found, consider specifying mapping for this name"
      return nil
    else
      new connection, user
    end
  end
end