Kanboard sync tool
==================

the script that fetches information from linked external systems and update cards

## Profiles and tasks

The idea is that different kanboard projects can use different configuration for similar tasks. Also some tasks might not be
applicable for every project. Each project can by managed by different users. Therefore we can define task as a generic, easy to
adapt action on a single kanboard project. A profile is a list of tasks, their configuration and other project specific configuration,
e.g. kanboard API token.

Profiles can choose what tasks should be run by using either a whitelist or black list. To create a new profile, simply copy
profiles/default.yml.example and adjust the configuration.

## Modes of run

For one-off shots you can use kansync.rb directly, e.g.

```
./kansync.rb task -p profiles/marek.yml
```

If you want to automate repeated runs, you can use kansync_loop script, the first argument is profile, the second one is interval which defaults
to 1 hour. The script tries to change pwd to /opt/app-root which is the directory, that docker container uses (see below).


## redmine_to_kanboard

There is a command to convert a Redmine ticket to a Kanboard task.

Before using, one needs to configure the `backlog_swimlane_name` in profile configuration:

```
configuration:
  backlog_swimlane_name: "Backlog"
```

Usage:

```
./kansync.rb redmine_to_kanboard -p profiles/remote.yml --redmine-id 12345
```

## Running it using docker

to build an image, do a something like

```
sudo docker build -t ares/kansync:latest .
```

then you can run the container like this

```
sudo docker run --name kansync --rm -i -t -v $PWD/profiles/:/opt/app-root/profiles ares/kansync kansync_loop
```

that prints the usage, to run specific profile from directory you mounted, do this

```
sudo docker run --name kansync --rm -i -t -v $PWD/profiles/:/opt/app-root/profiles ares/kansync kansync_loop profiles/my_profile.yml
```

By default the profile will be run every 600 seconds, you can customize the interval by additional parameter (value is in seconds)

```
sudo docker run --name kansync --rm -i -t -v $PWD/profiles/:/opt/app-root/profiles ares/kansync kansync_loop profiles/my_profile 60
```
