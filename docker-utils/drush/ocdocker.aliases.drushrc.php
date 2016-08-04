<?php

if (!isset($drush_major_version)) {
  $drush_version_components = explode('.', DRUSH_VERSION);
  $drush_major_version = $drush_version_components[0];
}
$aliases['docker-drupal'] = array(
  'root' => '/var/www/html/docker-drupal/docroot',
  'uri' => 'local.drupal.org',
  'remote-host' => 'local.drupal.org',
  'remote-user' => 'root',
);
