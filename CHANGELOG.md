# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Handle unused main.cf parameters that are unknown by postfix and not referenced
  in any other parameter (#3).

## Release [0.2.1] - 2018-02-05
Cosmetic release that removes outdated badges from README

### Fixed
- Remove oudated badges that belong to the upstream project this project
  was forked from.

## Release [0.2.0] - 2018-02-05
First release as oxc-postfix, now requires Puppet 4.9

### Added
- Support support for FreeBSD operating system

### Changed
- Minium required puppet version is now 4.9 for Hiera 5 support
- Move configuration to module hiera data
- Some lint/style changes

## jiuka-postfix [0.1.0] 2016-12-26

* Added postconf_master type and provider.

## jiuka-postfix [0.0.1] 2016-12-24

* Initial release

[Unreleased]: https://github.com/oxc/puppet-postfix/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/oxc/puppet-postfix/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/oxc/puppet-postfix/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/oxc/puppet-postfix/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/oxc/puppet-postfix/compare/f7d8b52...v0.0.1
