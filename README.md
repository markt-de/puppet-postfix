# postfix module for Puppet

[![Build Status](https://travis-ci.org/jiuka/puppet-postfix.png?branch=master)](https://travis-ci.org/jiuka/puppet-postfix)

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with postfix](#setup)
    * [What postfix affects](#what-postfix-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with postfix](#beginning-with-postfix)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)

## Description

Puppet module to manage your postfix installation. Manage postconf settings and
postfix instances with native types.

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

#### postmulti

The `postmulti` type allows you to create, de/activate and destroy postfix
postmulti instances with pupppet.

By default `ensure` is set to `active` but can be set to `inactive` or `absent`
respectively to deactivate or remove an postmulti instance.

As the postmulti the resource name must begin with `postfix-`.

```puppet
  postmulti { 'postfix-out': }
```
