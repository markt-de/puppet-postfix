# @summary Manages the postfix packages.
# @api private
class postfix::package inherits postfix {
  if ($postfix::package_manage) {
    package { 'postfix':
      ensure => $postfix::package_ensure,
      name   => $postfix::package_name,
    }

    if $::postfix::service_manage {
      exec { 'restart postfix service after packages install':
        command     => regsubst($::postfix::restart_cmd, 'reload', 'restart'),
        refreshonly => true,
        subscribe   => Package['postfix'],
      }
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
