<?php

/**
 * Plug installer function that generates sample pages and set our default options instead
 */

function wp_install_defaults() {
	global $CUSTOM_WP_CORE_NAME, $CUSTOM_WP_UPLOAD_NAME;

	// home = https://env.example.com
	update_option('home', str_replace("/".$CUSTOM_WP_CORE_NAME, "/", site_url()));

	// upload_path = /var/www/$CUSTOM_WP_UPLOAD_NAME
	update_option('upload_path', dirname(ABSPATH). "/" . $CUSTOM_WP_UPLOAD_NAME);

	// upload_url_path = https://env.example.com/$CUSTOM_WP_UPLOAD_NAME
	update_option('upload_url_path', home_url() . "/" . $CUSTOM_WP_UPLOAD_NAME);

	return null;
}
