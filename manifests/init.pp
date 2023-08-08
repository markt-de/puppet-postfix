# @summary This class installs and configures the postfix service.
#
# @param package_ensure
#   The state the postfix package should be ensured.
#
# @param package_manage
#   Whether to install the postfix and plugin packages.
#
# @param package_name
#   The name of the postfix package to install.
#
# @param service_ensure
#   The state of the postfix service which should be ensured.
#
# @param service_name
#   The name of the postfix service.
#
# @param service_manage
#   Should the postfix service be managed at all.
#
# @param mailx_manage
#   Should the mailx package me managed.
#
# @param mailx_ensure
#   The state of the mailx package to ensure.
#
# @param mailx_package
#   The name of the mailx package.
#
# @param plugin
#   Contains a package_name parameter for each plugin (if available).
#
# @param plugins
#   The list of plugins to install.
#
# @param purge_main
#   Purge all unmanaged entries from main.cf if true.
#
# @param purge_master
#   Purge all unmanaged entries from master.cf if true.
#
# @param main_config
#   A hash of config key-value entries for main.cf
#
# @param master_config
#   A hash of config key-value entries for master.cf
#
# @example Basic usage
#    class { 'postfix':
#      service_manage => false,
#      mailx_ensure   => absent
#    }
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
  ~> Class { '::postfix::service': }
}
