<?php

#ddev-generated: Remove this line to manage settings.php manually.

/**
 * Load default configuration.
 */
include $app_root . '/' . $site_path . '/default.settings.php';

/**
 * Load services definition file.
 */
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/default.services.yml';
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.yml';

/**
 * Location of the site configuration files.
 */
$settings['config_sync_directory'] = '../config/sync/';

/**
 * Public file path.
 */
$settings['file_public_path'] = 'sites/default/files';

/**
 * Private file path.
 */
$settings['file_private_path'] = '../private_files';

/**
 * Load local settings overrides.
 */
if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}

// Automatically generated include for settings managed by ddev.
$ddev_settings = dirname(__FILE__) . '/settings.ddev.php';
if (getenv('IS_DDEV_PROJECT') == 'true' && is_readable($ddev_settings)) {
  require $ddev_settings;
}
