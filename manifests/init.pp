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
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class postfix (
  ### START Package Configuration ###
  $package_ensure                 = present,
  $package_name                   = $::postfix::params::package_name,
  ### END Package Configuration ###

  ### START Service Configuation ###
  $service_ensure                 = running,
  $service_name                   = undef,
  $service_manage                 = true,
  ### END Service Configuration ###

  ### START mailx Configuration ###
  $mailx_manage = true,
  $mailx_ensure = present,
  $mailx_package = $::postfix::params::mailx_package,
  ### END mailx Configuration ###
) inherits ::postfix::params {

  class { '::postfix::package':  } ->
  class { '::postfix::service': }

}
