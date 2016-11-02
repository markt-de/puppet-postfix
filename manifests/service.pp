# Class: postfix::service
# ===========================
#
# Internal class: Manages the postfix service. 
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
class postfix::service {

  $service_enable = $::postfix::service_ensure ? {
    'running' => true,
    'absent'  => false,
    'stopped' => false,
    'undef'   => undef,
    default   => true,
  }

  $service_ensure_real = $::postfix::service_ensure ? {
    'undef' => undef,
    default => $::postfix::service_ensure
  }

  if $::postfix::service_manage {
    service { 'postfix':
      ensure     => $service_ensure_real,
      name       => $::postfix::service_name,
      enable     => $service_enable,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
