# Ansible-Podman-Rootless


Roles of podman binary installation and related system configuration for rootless container deployment  
whole process:  
1. Install podman package
2. Set cgroup permission for unpriviledged user
3. Set sysctl permission for unpriviledged user
4. Set subuid & subgid
5. Set linux kernel modules for podman rootless
6. Set podman socket service in system/user scope

## Requirements

Required ansible module:
- ansible.buildin
- ansible.posix
- community.general

Required system package:
- python3-jmespath

---
## Role Variables

### vars_package.podman
Config podman package
* `state`: required
  * `present`: <- default, install podman package
  * `absent`: uninstall podman package
  * `skipped`: skip the implement the podman package task
* `include_cockpit_podman`: 
  * `true`: install podman cockpit 
  * `false`: <- default, omit the installation of podman cockpit 
* `dnf`: optional, dnf related config to install podman for special requirement, e.g. install the latest version from update testing repo
  * `enablerepo`: Enabling the repositories temporarily, e.g. `updates-testing`
  * `update_cache`:
    * `true`: update cache for the enabled repo
    * `false`: do not update cache for the enabled repo

example:
```yaml
vars_package:
  podman:
    state: present
    include_cockpit_podman: false
    dnf:
      enablerepo: updates-testing
      update_cache: true
```

---
### target_user
target user to run rootless podman

example:
```yaml
target_user: "{{ ansible_user }}"
```

---
### vars_cgroups_delegation
Config cgroup delegation to unprivileged user

* `all_users`: Config cgroup delegation to all unprivileged user
  * `state`: present/absent/skipped
    * `present`: <- default  
      for systemd distro:  
        config cgroup delegate in `/etc/systemd/system/user@.service.d/delegate.conf`, according to the setting in `vars_cgroups_delegation.all_users.resources`  
      for openrc distro:  
        set "rc_cgroup_mode=unified" in `/etc/rc.conf`
    * `absent`:  
      remove cgroup config with this role own partten (if exist)
    * `skipped`:  
      skip the cgroup delegation config process for all users
  * `present_override`: 
    * `true`: override the origin cgroup delegation config when state set to present if exist
    * `false`: do not override the origin cgroup delegation config when state set to present if exist
  * `resources`: cgroup resources type which able to control by user
* `per_user`: cgroup delegation settings only work for systemd base distro
  * `state`: present/absent/skipped
    * `present`: config cgroup delegate in `/etc/systemd/system/user@{{ target_user_uid }}.service.d/delegate.conf` according to the setting in `vars_cgroups_delegation.pre_user.resources`
    * `absent`: remove cgroup config with this role own patten (if there)
    * `skipped`: skip the cgroup delegation config process for each target user, note: if podman package is not there, the cgroup delegate file create by this role will also be delete
  * `resources`: cgroup resources type which able to control by user

example:
```yaml
vars_cgroups_delegation:
  all_users:
    state: present
    present_override: false
    resources: cpu cpuset io memory pids
  per_user:
    state: skipped
    resources: cpu cpuset io memory pids
```

background: 
  - [Running containers with resource limits fails with a permissions error](https://github.com/containers/podman/blob/main/troubleshooting.md#26-running-contai)
  - [systemd Cgroup User delegation](https://wiki.archlinux.org/title/Cgroups#User_delegation)
  - [OpenRC CGroups version 2](https://wiki.gentoo.org/wiki/OpenRC/CGroups#CGroups_version_2_2)
  - [make sure the rc_cgroup_mode argument is set to unified](https://github.com/containers/podman/issues/11841#issuecomment-933596023)

---
### vars_sysctl_params
Config sysctl conf file `/etc/sysctl.d/{{ role_name }}.conf`:
* `state`: present/absent/skipped
  * `present`: <- default, create sysctl conf file `/etc/sysctl.d/{{ role_name }}.conf` for podman rootless according to vars_sysctl_params.list
  * `absent`: delete sysctl conf file `/etc/sysctl.d/{{ role_name }}.conf`
  * `skipped`: skip the implement of sysctl permission config task,  
  note: if podman package is not there, the sysctl conf file create by this role will also be delete
* `list`: list of config items for sysctl.conf
  * `name`: The dot-separated path (also known as key) specifying the sysctl variable.
  * `value`: Desired value of the sysctl key.

example: 
```yaml
vars_sysctl_params:
  state: present
  list:
    - name: net.ipv4.ping_group_range
      value: 0 2000000
    - name: net.ipv4.ip_unprivileged_port_start
      value: 53
```

background:
  - [rootless-containers-cannot-ping-hosts](https://github.com/containers/podman/blob/main/troubleshooting.md#5-rootless-containers-cannot-ping-hosts)
  - [Podman can not create containers that bind to ports < 1024.](https://github.com/containers/podman/blob/main/rootless.md#:~:text=Podman%20can%20not%20create%20containers%20that%20bind%20to%20ports%20%3C%201024)

---
### vars_pam_limits
Config security limits drop-in conf file `/etc/security/limits.d/{{ role_name }}-{{ target_user }}.conf` for podman rootless according to `vars_pam_limits.list`
* `state`: state of the pam limit drop-in file
  - `present`:  create security limits drop-in conf file `/etc/security/limits.d/{{ role_name }}-{{ target_user }}.conf` for podman rootless according to vars_pam_limits.list
  - `absent`: delete security limits drop-in conf file `/etc/security/limits.d/{{ role_name }}-{{ target_user }}.conf`
  - `skipped`: skip the implement of security limits drop-in conf file,  
  note: if podman package is not there, the security limits drop-in conf file create by this role will also be delete
* `list`: list of items to modify PAM limits, see [community.general.pam_limits module ](https://docs.ansible.com/ansible/latest/collections/community/general/pam_limits_module.html)
  * `comment`: Comment associated with the limit.
  * `limit_item`: The limit to be set.
  * `limit_type`: Limit type, see man 5 limits.conf for an explanation
  * `value`: The value of the limit.

example:
```yaml
vars_pam_limits:
  state: skipped
  list:
    - comment: add memory lock hard limit to {{ target_user }}
      limit_item: memlock
      limit_type: hard
      value: -1
    - comment: add memory lock soft limit to {{ target_user }}
      limit_item: memlock
      limit_type: soft
      value: -1
    - comment: add nproc limit to {{ target_user }}
      limit_item: nproc
      limit_type: hard
      value: 6418
```

background:
  - [How to run hashicorp vault as rootless container](https://github.com/containers/podman/issues/10051)
  - [How to Use the ulimit Linux Command](https://phoenixnap.com/kb/ulimit-linux-command)
  - [Cannot enter container – crun: setrlimit RLIMIT_NPROC: Operation not permitted: OCI permission denied](https://github.com/containers/toolbox/issues/1312)
  - [crun: setrlimit RLIMIT_NPROC: Operation not permitted: OCI permission denied ](https://github.com/fedora-silverblue/issue-tracker/issues/460)

  ```
  bash-5.1$ podman start gitlab-gitlab
  ERRO[0000] Starting some container dependencies         
  ERRO[0000] "crun: setrlimit `RLIMIT_NPROC`: Operation not permitted: OCI permission denied" 
  Error: unable to start container "5ab3087e1bcb158ddb3423f312db5d32e31f6da9b2d3811c17139e9f87182290": starting   some containers: internal libpod error

  bash-5.1$ podman inspect --format '{{ printf "%+v" .HostConfig.Ulimits }}' gitlab-gitlab
  [{Name:RLIMIT_NOFILE Soft:524288 Hard:524288} {Name:RLIMIT_NPROC Soft:6471 Hard:6471}]

  bash-5.1$ ulimit -u
  6418
  ```

---
### vars_sub_ids
Config etc/subuid and etc/subgid for podman container 
* `state`

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
