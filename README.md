# postfix module for Puppet

[![Build Status](https://travis-ci.org/jiuka/puppet-postfix.png?branch=master)](https://travis-ci.org/jiuka/puppet-postfix)
[![Coverage Status](https://coveralls.io/repos/github/jiuka/puppet-postfix/badge.svg?branch=master)](https://coveralls.io/github/jiuka/puppet-postfix?branch=master)

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with postfix](#setup)
    * [What postfix affects](#what-postfix-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with postfix](#beginning-with-postfix)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations](#limitations)
  * [Known Issues](#known-issues)

## Description

Puppet module to manage your postfix installation. Manage main.cf settings and master.cf entries by postconf backed native types. Both types include support for multiple postfix instances. The postfix instances can be managed with a native type too.

## Setup

### Setup Requirements

This module requires pluginsync to be enabled to sync the type/provider to the agent.

### Beginning with postfix

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

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

- The postfix version of el7 does not yet support postconf_master.

- The `puppet resource` interfacte is not working on postconf_master doe to [PUP-3732](https://tickets.puppetlabs.com/browse/PUP-3732)
