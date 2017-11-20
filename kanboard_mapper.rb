class KanboardMapper
  def initialize(profile:, redmine_issue:)
    @profile = profile
    @redmine_issue = redmine_issue
  end

  def tags
    tags = []
  end

  def category
    return unless @redmine_issue
    return @category if @category
    if foreman?
      category_name = @redmine_issue.category_name
    else
      category_name = @redmine_issue.project_name
    end
    return if category_name.nil?
    @category = KanboardCategory.find_or_create(@profile.project_id, category_name)
  end

  def foreman?
    @redmine_issue.project_name == 'Foreman'
  end
end