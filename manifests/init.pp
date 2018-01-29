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
  String $package_name,
  String $restart_cmd,
  Enum['absent', 'running', 'stopped'] $service_ensure,
  String $service_name,
  Boolean $service_manage,
) {
  Class { '::postfix::package':  }
  -> Class { '::postfix::service': }
}
