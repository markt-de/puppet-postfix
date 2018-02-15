# Class: postfix::package
# ===========================
#
# Internal class: Manages the postfix packages.
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
class postfix::package inherits postfix {
  if ($postfix::package_manage) {
    package { $postfix::package_name:
      ensure => $postfix::package_ensure,
    }

    # get a list of package names for all requested plugins
    $_list = $postfix::plugins.map |$_plugin| {
      $postfix::plugin.dig($_plugin, 'package_name')
    }

    # remove duplicates from the list
    $packages = unique($_list).filter|$value| { $value != undef }

    # install plugin packages
    $packages.each |$_package| {
      package { $_package:
        ensure => $postfix::package_ensure,
      }
    }
  }

  if ($::postfix::mailx_manage) {
    package { 'mailx':
      ensure => $::postfix::mailx_ensure,
      name   => $::postfix::mailx_package,
    }
  }
}
