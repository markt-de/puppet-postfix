# @summary Manages the postfix service. 
# @api private
class postfix::service inherits postfix {

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
      ensure    => $service_ensure_real,
      name      => $::postfix::service_name,
      enable    => $service_enable,
      hasstatus => true,
      restart   => $::postfix::restart_cmd,
    }
  }

}
