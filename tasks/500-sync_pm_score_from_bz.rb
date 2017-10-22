# TODO requires auth so we'll need to uz bzapi - https://wiki.mozilla.org/Bugzilla:BzAPI#Browsing_the_API
# rodzilla could be used but it requires username and password, there's no API token until BZ 5.0
project.current_tasks.each do |task|
  logger.info "Processing #{task.title}"

  if task.bugzilla_links?
    logger.info "... found #{task.bugzilla_links.size} bugzilla links"

    total_score = task.bugzilla_links.inject(0) do |sum, bugzilla_link|
      sum += Bugzilla.new(bugzilla_link.url).pm_score
    end

    logger.info "Setting the complexity #{total_score} for this task"
    task.set_complexity(total_score)

    logger.debug "\n"
  end
end