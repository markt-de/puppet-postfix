# postfix module for Puppet

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with postfix](#setup)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations](#limitations)
  * [Known Issues](#known-issues)

## Description

Puppet module to manage your postfix installation. Manage main.cf settings and master.cf entries by postconf backed native types. Both types include support for multiple postfix instances. The postfix instances can be managed with a native type too.

## Setup

### Setup Requirements

This module requires pluginsync to be enabled to sync the type/provider to the agent.

## Usage

The easiest way to use this module is to specify all desired configuration in Hiera.
Here is a close-to-real-life example:

```yaml
postfix::main_config:
  mynetworks:
    - '10.40.0.0/24'
    - '[::1]/128'
  inet_interfaces: all
  smtpd_use_tls: yes
  smtpd_tls_cert_file: &postfix_cert /etc/postfix/ssl/postfix.crt
  smtpd_tls_key_file: &postfix_key /etc/postfix/ssl/postfix.key
  smtpd_sasl_auth_enable: no # only enable for mandatory tls ports
  smtpd_sasl_type: dovecot
  smtpd_sasl_path: private/auth
  # sasl only encrypted
  smtpd_tls_auth_only: yes
  smtpd_tls_security_level: may
  virtual_transport: 'lmtp:unix:private/dovecot-lmtp'
  milter_protocol: 6
  common_milters: >-
    { inet:localhost:11332,
    connect_timeout=10s,
    default_action=accept }
  smtpd_milters: '$common_milters'
  non_smtpd_milters: '$common_milters'
  milter_mail_macros: i {mail_addr} {client_addr} {client_name} {auth_authen}

postfix::master_services:
  smtps/inet: { ensure: present }
  submission/inet: { ensure: present }
```

This will create `postconf` and `postconf_master` resources for each setting.
The resource types can also be used directly as described below.

By default, this module will warn about unmanaged config entries in any managed `main.cf`
and `master.cf`, but not remove them. To enable purging of those resources, set purge_main
and purge_master to true:

```yaml
postfix::purge_main: true
postfix::purge_master: true
```

## Reference

### Types

#### postconf

The `postconf` type enables you to set or rest postconf parameters.

```puppet
  postconf { 'myhostname':
    value => 'foo.bar',
  }
```

The `config_dir` param allows you to manage different postfix instances and the
`parameter` param allows you to define the postconf parameter independently from
the resource name.

```puppet
  postconf { 'myhostname':
    value => 'foo.bar',
  }

  postconf { 'foo:myhostname':
    parameter  => 'myhostname',
    config_dir => '/etc/postfix-foo',
    value      => 'foo.bar',
  }
```

#### postconf_master

The `postconf_master` type enables you to manage the master.cf entries.

```puppet
  postconf_master { 'mytransport/unix':
    command => 'smtp',
  }
```

The `config_dir` param allows you to manage different postfix instances and the
`service` and `type` param allows you to define the postconf_master service/type independently from
the resource name.

```puppet
  postconf_master { 'mytransport/unix':
    command => 'smtp',
  }

  postconf_master { 'foo:mytransport/unix':
    service    => 'mytransport',
    type       => 'unix',
    config_dir => '/etc/postfix-foo',
    command    => 'smtp',
  }
```

#### postmulti

The `postmulti` type allows you to create, de/activate and destroy postfix
postmulti instances with pupppet.

By default `ensure` is set to `active` but can be set to `inactive` or `absent`
respectively to deactivate or remove an postmulti instance.

As the postmulti the resource name must begin with `postfix-`.

```puppet
  postmulti { 'postfix-out': }
```

## Limitations
### Known Issues

- The postfix version of el7 does not support postconf_master. An alternative version is available from the [IUS Community Project](https://ius.io/).
