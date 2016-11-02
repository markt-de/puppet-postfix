class postfix::params {
  $package_name = 'postfix'
  case $::osfamily {
    'RedHat': {
      $mailx_package = 'mailx'
    }

    'Debian': {
      $mailx_package = $::lsbdistcodename ? {
        /sarge|etch|lenny/ => 'mailx',
        default            => 'bsd-mailx',
      }
    }

    'Suse': {
      $mailx_package = 'mailx'
    }

    default: {
      fail "Unsupported OS family '${::osfamily}'"
    }
  }
}
