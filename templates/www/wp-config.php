<?php

/**
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 * Determine environment
 */

// First try a file 'wp-config-environment.php'
include_once __DIR__ . '/wp-config-environment.php';
// If not set, try an environment variable WP_ENVIRONMENT_TYPE or use fallback
if (!defined('WP_ENVIRONMENT_TYPE')) {
	define('WP_ENVIRONMENT_TYPE', $_SERVER['WP_ENVIRONMENT_TYPE'] ?: 'production');
}
// Include environment specific configs
include_once __DIR__ . '/wp-config-'.WP_ENVIRONMENT_TYPE.'.php';

/**
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 * Custom directory structure
 */

$CUSTOM_WP_CORE_NAME = '{{CORE_DIR_NAME}}'; // core
$CUSTOM_WP_CONTENT_NAME = '{{CONTENT_DIR_NAME}}'; // public
$CUSTOM_WP_UPLOAD_NAME = '{{UPLOADS_DIR_NAME}}'; // media

define('WP_CONTENT_URL', "https://" . $_SERVER['HTTP_HOST'] . '/' . $CUSTOM_WP_CONTENT_NAME);
define('WP_CONTENT_DIR', __DIR__ . '/' . $CUSTOM_WP_CONTENT_NAME);
define('WP_ROOT', __DIR__ . '/' . $CUSTOM_WP_CORE_NAME);

/**
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 * Shared configuration, most propbably unchanged.
 * If this changes for one environment, move it to ALL the wp-config-*.php file
 */

// Database
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', 'utf8_general_ci');

// MySQL database user tables
// define('CUSTOM_USER_TABLE', $table_prefix . 'accounts');
// define('CUSTOM_USER_META_TABLE', $table_prefix . 'accountsmeta');

// Server settings
// define('WP_MEMORY_LIMIT', '128M');
// define('WP_MAX_MEMORY_LIMIT', '256M');

// Misc. Wordpress behaviour
define('WP_DEFAULT_THEME', 'blank-theme');
// Disables auto update
define('AUTOMATIC_UPDATER_DISABLED', true);
define('WP_AUTO_UPDATE_CORE', false);

// skip wp-content when upgrading to a new wp version
define('CORE_UPGRADE_SKIP_NEW_BUNDLED', true);

// disable alle file modifincations for core, plugin and theme
// define('DISALLOW_FILE_MODS', false);
// disable plugin/theme editor
define('DISALLOW_FILE_EDIT', true);

//
// DB repair: ../wp-admin/maint/repair.php
// define('WP_ALLOW_REPAIR', true);

define('AUTOSAVE_INTERVAL', '180');
define('WP_POST_REVISIONS', '5');
define('MEDIA_TRASH', true);
define('EMPTY_TRASH_DAYS', '30');
define('COMPRESS_CSS', true);
define('COMPRESS_SCRIPTS', true);
define('ENFORCE_GZIP', true);
// define('WP_CACHE', false);
// define('WP_ALLOW_MULTISITE', false);

// SSL
define('FORCE_SSL_LOGIN', true);
define('FORCE_SSL_ADMIN', true);


/**
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 *
 * Initial PHP settings and Wordpress bootstrap
 */

if (!defined('ABSPATH')) {
	define('ABSPATH', dirname(__FILE__) . '/' . $CUSTOM_WP_CORE_NAME . '/');
}

require_once ABSPATH . 'wp-settings.php';
