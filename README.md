# WordPress Install Script

This is a boilerplate and installation script for WordPress with the WP core as a dependency and some other stuff. This new version moves away from PHP in favor of a shell script.

### Assumptions

-   You want to manage WordPress using Composer.
-   You want to have multiple runtime environments for development and production.
-   You want a better folder structure for your WordPress installation.
-   You want to automate some setup steps.
-   You want to use HTTPS on your site.

### Running the installer will…

-   Download the repository and prepare the custom folder structure.
-   Creates project files: readme.md, changelog.md, tasks.todo, notes.md, and a humans.txt
-   Rename the `core` and `wp-content` folders.
-   Create an `uploads` folder outside of wp-content.
-   Set runtime environment configurations.
-   Create fresh secret keys for each runtime environment.
-   Create a minimal `composer.json` for you to configure.

## Instructions

1. Download the `wpinit.sh` file
2. Execute it in the folder of your choice (`chmod +x wpinit.sh` `./wpinit.sh`)
3. Or make it globally available (`sudo mv wpinit.sh /usr/local/bin/wpinit`)
4. Set your environment (see below), default is 'production'
5. Double check `wp-config.php` and edit your environment configs `wp-config-*.php`
6. Configure `composer.json` and add more plugins
7. Run `composer install`
8. Continue with the usual Wordpress installation in your browser

## Setting the environment

### Via config file

Create or edit a file `/wp-config-environment.php` with a content like

```
<?php
define('WP_ENVIRONMENT_TYPE', 'production');
```

## changelog

### [2.0.0] - 2025-04-27

-   new template files
-   new script file
-   See https://github.com/moritzjacobs/wordpress-boilerplate for previous versions
