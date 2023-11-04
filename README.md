[![tests](https://github.com/wotnak/ddev-farmos/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-addon-template/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

# ddev-farmos

[DDEV](https://ddev.com) addon for [farmOS](https://farmos.org/). It will configure DDEV project for running farmOS.

## How to use

To start farmOS project using DDEV, run the following commands:

```shell
mkdir farmos
cd farmos
FARMOS_VERSION=3 # 2 or 3
ddev config --project-type=php
ddev get wotnak/ddev-farmos --version=$FARMOS_VERSION
ddev composer create farmos/project:$FARMOS_VERSION.x-dev
ddev drush site:install farm --account-name=admin --account-pass=admin -y
ddev launch
```
