[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com) [![tests](https://github.com/wotnak/ddev-farmos/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/wotnak/ddev-farmos/actions/workflows/tests.yml?query=branch%3Amain) [![last commit](https://img.shields.io/github/last-commit/wotnak/ddev-farmos)](https://github.com/wotnak/ddev-farmos/commits) [![release](https://img.shields.io/github/v/release/wotnak/ddev-farmos)](https://github.com/wotnak/ddev-farmos/releases/latest)

# ddev-farmos

[DDEV](https://ddev.com) addon for [farmOS](https://farmos.org/). It will configure DDEV project for running farmOS.

## How to use

To start farmOS project using DDEV, run the following commands:

```shell
mkdir farmos
cd farmos
ddev config --project-type=php
ddev add-on get wotnak/ddev-farmos
ddev restart
ddev composer create-project farmos/project:4.x-dev
ddev drush site:install farm --account-name=admin --account-pass=admin -y
ddev launch
```
