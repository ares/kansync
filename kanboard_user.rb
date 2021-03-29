require 'kanboard_resource'

class KanboardUser < KanboardResource
  def self.find_by_name(name)
    user = all_users.find { |u| u['name'] == name }
    if user.nil?
      Kansync.logger.error "Kanboard user with name #{name} not found, consider specifying mapping for this name"
      return nil
    else
      new user
    end
  end

  def self.find_by_id(id)
    user = connection.request('getUser', 'user_id' => id)
    if user.nil?
      Kansync.logger.error "Kanboard user with id #{name} not found"
      return nil
    else
      new user
    end
  end

  def self.all_users
    @all_users ||= connection.request('getAllUsers')
  end
end
