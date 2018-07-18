# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [2.0.0] - 2018-07-18

### Changed
- PHP installation process improved [PR-21](https://github.com/OXID-eSales/oxvm_base/pull/21)
- PHP 7.1 is installed by default.

### Removed
- phpbrew and phpswitch functionality was removed, as it was giving unstable results. 

## [1.1.3] - 2018-07-12

### Changed
- Change permissions of `/vagrant` share only for Windows ([ansible issue](https://github.com/ansible/ansible/issues/42388))

## [1.1.2] - 2018-07-11

### Changed
- Set permissions for shared directory since Ansible's behaviour changed in 2.6.1

## [1.1.1] - 2018-05-15

### Changed
- Remove triggers plugin requirement if Vagrant version is >= 2.1.0

## [1.1.0] - 2017-11-22

### Added
- Selenium role
- Landing page with installation role

### Changed
- Switched packages source to german sources by default
- README now contains configuration information
- Varnish setup information

[2.0.0]: https://github.com/OXID-eSales/oxvm_base/compare/v1.1.3...v2.0.0
[1.1.3]: https://github.com/OXID-eSales/oxvm_base/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/OXID-eSales/oxvm_base/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/OXID-eSales/oxvm_base/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/OXID-eSales/oxvm_base/compare/v1.0.0...v1.1.0
