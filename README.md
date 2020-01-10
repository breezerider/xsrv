```
  ╻ ╻┏━┓┏━┓╻ ╻
░░╺╋╸┗━┓┣┳┛┃┏┛
  ╹ ╹┗━┛╹┗╸┗┛ 
```

Run your own network services, on a server you control.

This [ansible](https://en.wikipedia.org/wiki/Ansible_(software)) playbook lets you quickly and reliably install and manage various network services and applications on your own servers. A simple command-line wrapper is provided for initial deployment and occasional maintenance tasks.

[![](https://gitlab.com/nodiscc/xsrv/badges/master/pipeline.svg)](https://gitlab.com/nodiscc/xsrv/commits/master)

## Roles

The following components (_roles_) are available:

- [common](https://gitlab.com/nodiscc/ansible-xsrv-common) - base server components (SSH, automatic updates, users, hostname, networking, kernel, time/date, logging...)
- [backup](https://gitlab.com/nodiscc/ansible-xsrv-backup) - incremental backup service (local and remote backups)
- [monitoring](https://gitlab.com/nodiscc/ansible-xsrv-monitoring) - lightweight server monitoring system (netdata and additional tools)
- [lamp](https://gitlab.com/nodiscc/ansible-xsrv-lamp) - Apache web server, PHP interpreter and MariaDB (MySQL) database server
- [nextcloud](https://gitlab.com/nodiscc/ansible-xsrv-lamp) - File hosting/sharing/synchronization/groupware/"private cloud" service.

<!-- TODO demo screencast -->

**Table of contents**

<!-- MarkdownTOC -->

- [Installation](#installation)
  - [Preparing the server](#preparing-the-server)
  - [Initial configuration/deployment](#initial-configurationdeployment)
- [Usage](#usage)
- [Configuration](#configuration)
- [Maintenance](#maintenance)
  - [Backups](#backups)
  - [Updates](#updates)
  - [Other maintenance](#other-maintenance)
- [License](#license)

<!-- /MarkdownTOC -->

------------


## Installation

You will need a server (_host_) to run your services, and a _controller_ machine to remotely deploy and administrate the server.


### Preparing the server

See **[Server preparation](server-preparation.md)**


### Initial configuration/deployment

From the _controller_:

```bash
# clone the playbook
git clone -b 1.0 https://gitlab.com/nodiscc/xsrv

# enter the playbook directory - all commands must be run from this directory
cd xsrv

# install ansible
./xsrv install-ansible
# set required configuration variables
./xsrv init

# If needed, change the list of enabled roles and/or host configuration variables
./xsrv config-playbook
./xsrv config-host

# Run host deployment
./xsrv deploy
```

After the deployment completes, your services are ready to use. Consult `data/my.example.org.html` for a quick access list.


## Usage

See [roles](#roles)


## Configuration

**Enabling more roles:**

```bash
# To add more roles to your server, uncomment them in inventory.yml
./xsrv config-playbook
```

**Host configuration:** The default configuration should work out of the box for a single server.

```bash
# To show or edit your host's configuration variables, edit host_vars/my.example.org.yml
./xsrv config-host

# By default, host variables only override some default values provided by roles.
# To show role defaults for all variables, review each role's default/main.yml
# Copy any setting from these defaults to your host variables file, and edit its value.
./xsrv show-defaults

```

**After any changes to configuration/roles**, apply changes: 

```bash
./xsrv deploy
```


## Maintenance

Self-hosting places your services and data under your own responsibility (uptime, backups, security...). Always have a plan in place if your server crashes, gets compromised or damaged. There is no High Availability mechanism configured by default.

The command-line utility `xsrv` provides easy access to common maintenance/diagnostic tasks:

```bash
$ ./xsrv help
USAGE: ./xsrv COMMAND
AVAILABLE COMMANDS:
install-ansible     install ansible in a virtualenv
init                initialize the playbook from example files
deploy              deploy the host (run ansible playbook)
config-host         edit host configuration
config-playbook     edit the playbook (host roles)
config-inventory    edit hosts inventory
show-defaults       show roles configuration defaults
check               simulate deployment/report items that would be changed
shell               open a SSH shell on the host
logs                view system logs on the host
netstat             view network connections on the host
backup-force        force a backup on the host
backup-fetch        fetch latest daily backups from the host
web                 open the hosts main homepage in a web browser
upgrade             upgrade playbook and roles to latest stable versions (read the release notes)
upgrade-dev         upgrade playbook and roles to latest development versions
ansible-playbook    run a raw ansible-playbook command
help                show this message
```

### Backups

Backups can be configured in the `##### BACKUPS #####` section of your host configuration variables. See the [backup](https://gitlab.com/nodiscc/ansible-xsrv-backup) role. To download a copy of the latest backups from the host, to the controller (`backups/` under the playbook directory), run:

```bash
./xsrv backup-fetch
```

### Updates

Security upgrades for Debian packages are applied [automatically/daily](https://gitlab.com/nodiscc/ansible-xsrv-common). To upgrade roles to their latest versions (bugfixes, new features, up-to-date versions of all third-party/web applications...):

- Download latest backups from the server and/or do a snapshot of the VM.
- Read the [release notes](releases), adjust your configuration variables if needed `./xsrv config-host`.
- Update the playbook to the latest release: `./xsrv upgrade`
- Run checks and watch out for unwated changes `./xsrv check`
- Deploy the playbook `./xsrv deploy`


### Other maintenance

**Tracking configuration in git:** By default your specific playbook/inventory/host_vars configuration is excluded from git to prevent accidentally pushing you configuration details to a public git repository. See [.gitignore](.gitignore) and disable relevant sections to start tracking your configuration in git.

**Uninstalling roles** is not supported at this time: components must be removed manually, or a new server must be deployed and data restored from backups.

**Testing/reverting updates:** The easiest way is probably to restore a snapshot from just before the upgrade (if your server is virtualized)

- Restore previous configuration variables
- Roll back roles to their previous versions (`git checkout $previous_version && ansible-galaxy -f -r requirements.yml`).
- Run the playbook:  `ansible-playbook playbook.yml`
- Restore data from the last known good backups (see each role's documentation for restore instructions)
- For professional/production systems, running the playbook and evaluating changes against a testing environment first is recommended.


## License

[GNU GPLv3](LICENSE)
