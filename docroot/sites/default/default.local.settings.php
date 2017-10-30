<?php

ini_set('memory_limit','1024M');
ini_set('max_execution_time',0);

$update_free_access = FALSE;

$drupal_hash_salt = 'WR5Z4NB0zTahinNOuCq36kWBRaUsyJsyuQCyEukbbv4';

ini_set('session.gc_probability', 1);
ini_set('session.gc_divisor', 100);

ini_set('session.gc_maxlifetime', 200000);

ini_set('session.cookie_lifetime', 0);

$databases = array(
    'default' => array(
        'default' => array(
            'database' => 'drupal',
            'username' => 'root',
            'password' => 'root',
            'host' => 'database',
            'port' => '',
            'driver' => 'mysql',
            'prefix' => '',
        ),
    ),
);

// Show all errors
// $conf['error_level'] = 2;

//$conf['env'] = 'local.dev';

// Disable anonymous page cache
$conf['cache'] = 0;
$conf['cache_lifetime'] = 0;
$conf['page_compression'] = 0;

// Disable aggregation of CSS / JS
$conf['preprocess_css'] = 0;
$conf['preprocess_js'] = 0;

//$conf['user_mail_register_pending_approval_notify'] = FALSE;
//$conf['user_mail_register_no_approval_required_notify'] = FALSE;
//$conf['user_registrationpassword_register_notify'] = FALSE;

// File system.
$conf['file_temporary_path'] = '/tmp';
$conf['file_public_path'] = conf_path().'/files';
$conf['file_private_path'] = conf_path(). '/files/private';

// Don't waste time on 404 images.
$conf['404_fast_paths_exclude'] = '/^asdoinweofnoiajdgoasdf$/';
$conf['404_fast_paths'] = '/\.(?:txt|png|gif|jpe?g|css|js|ico|swf|flv|cgi|bat|pl|dll|exe|asp)$/i';
$conf['404_fast_html'] = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><title>404 Not Found</title></head><body><h1>Not Found</h1><p>The requested URL "@path" was not found on this server.</p></body></html>';

// Disable shield.
$conf['shield_enabled'] = 0;

// Mount keys in the .drush/ directory.

// Sniff for the X_FORWARDED_PROTO header to make sure HTTPS works

if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    $_SERVER['HTTPS'] = 'On';
}

//$conf['memcache_servers'] = array('memcached:11211' => 'default');
//$conf['cache_backends'][] = 'sites/all/modules/contrib/memcache/memcache.inc';
//$conf['cache_default_class'] = 'MemCacheDrupal';
//$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';
//$conf['memcache_key_prefix'] = $_SERVER['SERVER_NAME'];