# Class: postfix
# ===========================
#
# This class installs and configures the postfix service.
#
# Parameters
# ----------
#
# * `package_ensure`
# The state the postfix package should be ensured.
#
# * `package_manage`
# Whether to install the postfix and plugin packages.
#
# * `package_name`
# * `package_name`
# The name of the postfix package to install.
#
# * `service_ensure`
# The state of the postfix service which should be ensured.
#
# * `service_name`
# The name of the postfix service.
#
# * `service_manage`
# Should the postfix service be managed at all.
#
# * `mailx_manage`
# Should the mailx package me managed.
#
# * `mailx_ensure`
# The state of the mailx package to ensure.
#
# * `mailx_package`
# The name of the mailx package.
#
# * `plugin`
# Contains a package_name parameter for each plugin (if available).
#
# * `plugins`
# The list of plugins to install.
#
# * `purge_main`
# Purge all unmanaged entries from main.cf if true.
#
# * `purge_master`
# Purge all unmanaged entries from master.cf if true.
#
# * `main_config`
# A hash of config key-value entries for main.cf
#
# * `master_config`
# A hash of config key-value entries for master.cf
#
# Examples
# --------
#
# @example
#    class { 'postfix':
#      service_manage => false,
#      mailx_ensure   => absent
#    }
#
# Authors
# -------
#
# Marius Rieder <marius.rieder@durchmesser.ch>
# Bernhard Frauendienst <puppet@nospam.obeliks.de>
#
# Copyright
# ---------
#
# Copyright 2016 Marius Rieder <marius.rieder@durchmesser.ch>
# Copyright 2017 Bernhard Frauendienst <puppet@nospam.obeliks.de>
#
class postfix (
  Enum['installed', 'present', 'latest'] $mailx_ensure,
  Boolean $mailx_manage,
  String $mailx_package,
  Enum['installed', 'present', 'latest'] $package_ensure,
  Boolean $package_manage,
  String $package_name,
  Hash $plugin,
  Array[String[1]] $plugins,
  Variant[Boolean, Enum['true', 'false', 'noop']] $purge_main, # lint:ignore:quoted_booleans
  Variant[Boolean, Enum['true', 'false', 'noop']] $purge_master, # lint:ignore:quoted_booleans
  String $restart_cmd,
  Enum['absent', 'running', 'stopped'] $service_ensure,
  String $service_name,
  Boolean $service_manage,
  Hash[String, Any] $main_config,
  Hash[String, Hash[String, Any]] $master_services,
) {
  Class { '::postfix::package':  }
  -> Class { '::postfix::config': }
  -> Class { '::postfix::service': }
}
