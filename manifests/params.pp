class postfix::params {
  $package_name = 'postfix'
  case $::osfamily {
    'RedHat': {
      $restart_cmd = $::operatingsystemmajrelease ? {
        '7'     => '/bin/systemctl reload postfix',
        default => '/etc/init.d/postfix reload',
      }

      $mailx_package = 'mailx'
    }

    'Debian': {
      $restart_cmd = '/etc/init.d/postfix reload'

      $mailx_package = $::lsbdistcodename ? {
        /sarge|etch|lenny/ => 'mailx',
        default            => 'bsd-mailx',
      }
    }

    'Suse': {
      if $::operatingsystemmajrelease == '11' {
        $restart_cmd = '/etc/init.d/postfix reload'
      } else {
        $restart_cmd = '/usr/bin/systemctl reload postfix'
      }

      $mailx_package = 'mailx'
    }

    default: {
      fail "Unsupported OS family '${::osfamily}'"
    }
  }
}
