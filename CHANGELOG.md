# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Notify service on config changes, causing it to reload postfix to pick up the
  changes([#7])

## Release [1.0.1] - 2018-09-27
This release fixes support for systems where postfix is not installed, and
bumps stdlib version compatibility.

### Added
- Support for puppetlabs/stdlib 5
- Support for Ubuntu 18.04

### Fixed
- Make postfix fact not cause trouble on systems where postfix is not installed ([#6])

## Release [1.0.0] - 2018-03-03
First stable release

### Added
- Add new parameter `$plugins` to specify a list of postfix plugins that should be installed ([#2])
- Add new parameter `$plugin` to configure plugin package names ([#2])
- Add new parameter `$package_manage` to control wether packages should be installed or not ([#2])
- Add new parameters `$main_config` and `$master_services` to easily specify configuration via Hiera ([#4])
- Add CLI script to convert an existing master.cf to hiera YAML ([#4])
- Add new parameters `$purge_main` and `$purge_master` to remove unmanaged entries (default: warn about unmanaged entries) ([#5])

### Changed
- Boolean properties in `postconf_master` now accept more values
- Add stdlib dependency for unique() function on Puppet 4.x ([#2])

### Fixed
- Handle unused main.cf parameters that are unknown by postfix and not referenced
  in any other parameter ([#3]).
- Fix service logic: move exec `restart after package install` to class `postfix::package` ([#2])
- Fix rspec unit tests
- Fix lots of rubocop-reported logic and style issues

## Release [0.2.1] - 2018-02-05
Cosmetic release that removes outdated badges from README

### Fixed
- Remove oudated badges that belong to the upstream project this project
  was forked from.

## Release [0.2.0] - 2018-02-05
First release as oxc-postfix, now requires Puppet 4.9

### Added
- Support support for FreeBSD operating system ([#1])

### Changed
- Minium required puppet version is now 4.9 for Hiera 5 support ([#1])
- Move configuration to module hiera data ([#1])
- Some lint/style changes ([#1])

## jiuka-postfix [0.1.0] 2016-12-26

* Added postconf_master type and provider.

## jiuka-postfix [0.0.1] 2016-12-24

* Initial release

[Unreleased]: https://github.com/oxc/puppet-postfix/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/oxc/puppet-postfix/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/oxc/puppet-postfix/compare/v0.2.1...v1.0.0
[0.2.1]: https://github.com/oxc/puppet-postfix/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/oxc/puppet-postfix/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/oxc/puppet-postfix/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/oxc/puppet-postfix/compare/f7d8b52...v0.0.1
[#7]: https://github.com/oxc/puppet-postfix/issues/7
[#6]: https://github.com/oxc/puppet-postfix/pull/6
[#5]: https://github.com/oxc/puppet-postfix/issues/5
[#4]: https://github.com/oxc/puppet-postfix/issues/4
[#3]: https://github.com/oxc/puppet-postfix/issues/3
[#2]: https://github.com/oxc/puppet-postfix/pull/2
[#1]: https://github.com/oxc/puppet-postfix/pull/1
