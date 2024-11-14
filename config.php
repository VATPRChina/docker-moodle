<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype = getenv('DB_TYPE') ?: 'mariadb';
$CFG->dblibrary = 'native';
$CFG->dbhost = getenv('DB_HOST') ?: '127.0.0.1';
$CFG->dbname = getenv('DB_NAME') ?: 'moodle';
$CFG->dbuser = getenv('DB_USER') ?: 'root';
$CFG->dbpass = getenv('DB_PASS') ?: '';
$CFG->prefix = getenv('DB_PREFIX') ?: 'mdl_';
$CFG->dboptions = array(
  'dbpersist' => 0,
  'dbport' => getenv('DB_PORT') ?: '3306',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

$CFG->wwwroot = getenv('MOODLE_WWWROOT') ?: 'https://example.com';
$CFG->dataroot = getenv('MOODLE_DATA_ROOT') ?: '/var/www/moodledata';
$CFG->admin = getenv('MOODLE_ADMIN') ?: 'admin';

$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!

