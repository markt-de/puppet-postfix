# Class: postfix::package
# ===========================
#
# Internal class: Manages the postfix packages.
#
# Authors
# -------
#
# Marius Rieder <marius.rieder@durchmesser.ch>
#
# Copyright
# ---------
#
# Copyright 2016 Marius Rieder <marius.rieder@durchmesser.ch>
#
class postfix::package {
  package { 'postfix':
    ensure => $::postfix::package_ensure,
    name   => $::postfix::package_name,
  }

  if ($::postfix::mailx_manage) {
    package { 'mailx':
      ensure => $::postfix::mailx_ensure,
      name   => $::postfix::mailx_package,
    }
  }
}
