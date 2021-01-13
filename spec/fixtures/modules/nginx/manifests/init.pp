# @summary
#   This module manages NGINX.
#
# Parameters:
#
# Actions:
#
# Requires:
#  puppetlabs-stdlib - https://github.com/puppetlabs/puppetlabs-stdlib
#
#  Packaged NGINX
#    - RHEL: EPEL or custom package
#    - Debian/Ubuntu: Default Install or custom package
#    - SuSE: Default Install or custom package
#
#  stdlib
#    - puppetlabs-stdlib module >= 0.1.6
#
# Sample Usage:
#
# The module works with sensible defaults:
#
# node default {
#   include nginx
# }
#
# @param include_modules_enabled
#   When set, nginx will include module configurations files installed in the
#   /etc/nginx/modules-enabled directory.
#
# @param passenger_package_name
#   The name of the package to install in order for the passenger module of
#   nginx being usable.
#
# @param nginx_version
#   The version of nginx installed (or being installed).
#   Unfortunately, different versions of nginx may need configuring
#   differently.  The default is derived from the version of nginx
#   already installed.  If the fact is unavailable, it defaults to '1.6.0'.
#   You may need to set this manually to get a working and idempotent
#   configuration.
#
# @param debug_connections
#   Configures nginx `debug_connection` lines in the `events` section of the nginx config.
#   See http://nginx.org/en/docs/ngx_core_module.html#debug_connection
#
# @param service_config_check
#  whether to en- or disable the config check via nginx -t on config changes
#
class nginx (
  ### START Nginx Configuration ###
  $client_body_temp_path                                         = undef,
  Boolean $confd_only                                            = false,
  Boolean $confd_purge                                           = false,
  $conf_dir                                                      = '/etc/nginx',
  Optional[Enum['on', 'off']] $daemon                            = undef,
  $daemon_user                                                   = 'nginx',
  $daemon_group                                                  = undef,
  Array[String] $dynamic_modules                                 = [],
  $global_owner                                                  = 'root',
  $global_group                                                  = 'root',
  $global_mode                                                   = '0644',
  Optional[Variant[String[1], Array[String[1]]]] $limit_req_zone = undef,
  $log_dir                                                       = undef,
  String[1] $log_user                                            = 'nginx',
  String[1] $log_group                                           = 'root',
  $log_mode                                                      = undef,
  $http_access_log                                               = undef,
  $http_format_log                                               = undef,
  $nginx_error_log                                               = undef,
  $nginx_error_log_severity                                      = 'error',
  $pid                                                           = undef,
  $proxy_temp_path                                               = undef,
  $root_group                                                    = undef,
  $run_dir                                                       = undef,
  $sites_available_owner                                         = undef,
  $sites_available_group                                         = undef,
  $sites_available_mode                                          = undef,
  Boolean $super_user                                            = true,
  $temp_dir                                                      = undef,
  Boolean $server_purge                                          = false,
  Boolean $include_modules_enabled                               = false,

  # Primary Templates
  $conf_template                                                 = 'nginx/conf.d/nginx.conf.erb',

  ### START Nginx Configuration ###
  Optional[Enum['on', 'off']] $absolute_redirect                 = undef,
  Enum['on', 'off'] $accept_mutex                                = 'on',
  $accept_mutex_delay                                            = '500ms',
  $client_body_buffer_size                                       = '128k',
  String $client_max_body_size                                   = '10m',
  $client_body_timeout                                           = '60s',
  $send_timeout                                                  = '60s',
  $lingering_timeout                                             = '5s',
  Optional[Enum['on', 'off']] $etag                              = undef,
  Optional[String] $events_use                                   = undef,
  $debug_connections                                             = [],
  String $fastcgi_cache_inactive                                 = '20m',
  Optional[String] $fastcgi_cache_key                            = undef,
  String $fastcgi_cache_keys_zone                                = 'd3:100m',
  String $fastcgi_cache_levels                                   = '1',
  String $fastcgi_cache_max_size                                 = '500m',
  Optional[String] $fastcgi_cache_path                           = undef,
  Optional[String] $fastcgi_cache_use_stale                      = undef,
  Enum['on', 'off'] $gzip                                        = 'off',
  $gzip_buffers                                                  = undef,
  $gzip_comp_level                                               = 1,
  $gzip_disable                                                  = 'msie6',
  $gzip_min_length                                               = 20,
  $gzip_http_version                                             = 1.1,
  $gzip_proxied                                                  = 'off',
  $gzip_types                                                    = undef,
  Enum['on', 'off'] $gzip_vary                                   = 'off',
  Optional[Enum['on', 'off', 'always']] $gzip_static             = undef,
  Optional[Variant[Hash, Array]] $http_cfg_prepend               = undef,
  Optional[Variant[Hash, Array]] $http_cfg_append                = undef,
  Optional[Variant[Array[String], String]] $http_raw_prepend     = undef,
  Optional[Variant[Array[String], String]] $http_raw_append      = undef,
  Enum['on', 'off'] $http_tcp_nodelay                            = 'on',
  Enum['on', 'off'] $http_tcp_nopush                             = 'off',
  $keepalive_timeout                                             = '65s',
  $keepalive_requests                                            = '100',
  $log_format                                                    = {},
  Boolean $mail                                                  = false,
  Variant[String, Boolean] $mime_types_path                      = 'mime.types',
  Boolean $stream                                                = false,
  String $multi_accept                                           = 'off',
  Integer $names_hash_bucket_size                                = 64,
  Integer $names_hash_max_size                                   = 512,
  $nginx_cfg_prepend                                             = false,
  String $proxy_buffers                                          = '32 4k',
  String $proxy_buffer_size                                      = '8k',
  String $proxy_cache_inactive                                   = '20m',
  String $proxy_cache_keys_zone                                  = 'd2:100m',
  String $proxy_cache_levels                                     = '1',
  String $proxy_cache_max_size                                   = '500m',
  Optional[Variant[Hash, String]] $proxy_cache_path              = undef,
  Optional[Integer] $proxy_cache_loader_files                    = undef,
  Optional[String] $proxy_cache_loader_sleep                     = undef,
  Optional[String] $proxy_cache_loader_threshold                 = undef,
  Optional[Enum['on', 'off']] $proxy_use_temp_path               = undef,
  $proxy_connect_timeout                                         = '90s',
  Integer $proxy_headers_hash_bucket_size                        = 64,
  Optional[String] $proxy_http_version                           = undef,
  $proxy_read_timeout                                            = '90s',
  $proxy_redirect                                                = undef,
  $proxy_send_timeout                                            = '90s',
  Array $proxy_set_header                                        = [
    'Host $host',
    'X-Real-IP $remote_addr',
    'X-Forwarded-For $proxy_add_x_forwarded_for',
    'Proxy ""',
  ],
  Array $proxy_hide_header                                       = [],
  Array $proxy_pass_header                                       = [],
  Array $proxy_ignore_header                                     = [],
  $proxy_max_temp_file_size                                      = undef,
  $proxy_busy_buffers_size                                       = undef,
  Enum['on', 'off'] $sendfile                                    = 'on',
  Enum['on', 'off'] $server_tokens                               = 'on',
  Enum['on', 'off'] $spdy                                        = 'off',
  Enum['on', 'off'] $http2                                       = 'off',
  Enum['on', 'off'] $ssl_stapling                                = 'off',
  Enum['on', 'off'] $ssl_stapling_verify                         = 'off',
  $snippets_dir                                                  = undef,
  Boolean $manage_snippets_dir                                   = true,
  $types_hash_bucket_size                                        = '512',
  $types_hash_max_size                                           = '1024',
  Integer $worker_connections                                    = 1024,
  Enum['on', 'off'] $ssl_prefer_server_ciphers                   = 'on',
  Variant[Integer, Enum['auto']] $worker_processes               = 'auto',
  Integer $worker_rlimit_nofile                                  = 1024,
  String $ssl_protocols                                          = 'TLSv1 TLSv1.1 TLSv1.2',
  String $ssl_ciphers                                            =
  'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS'
  , # lint:ignore:140chars
  $ssl_dhparam                                                   = undef,
  Optional[String] $ssl_ecdh_curve                               = undef,
  String $ssl_session_cache                                      = 'shared:SSL:10m',
  String $ssl_session_timeout                                    = '5m',
  Optional[Enum['on', 'off']] $ssl_session_tickets               = undef,
  $ssl_session_ticket_key                                        = undef,
  Optional[String] $ssl_buffer_size                              = undef,
  $ssl_crl                                                       = undef,
  $ssl_stapling_file                                             = undef,
  Optional[String] $ssl_stapling_responder                       = undef,
  $ssl_trusted_certificate                                       = undef,
  Optional[Integer] $ssl_verify_depth                            = undef,
  $ssl_password_file                                             = undef,

  ### START Package Configuration ###
  $package_ensure                                                = present,
  $package_name                                                  = undef,
  $package_source                                                = 'nginx',
  $package_flavor                                                = undef,
  Boolean $manage_repo                                           = false,
  $mime_types                                                    = undef,
  Boolean $mime_types_preserve_defaults                          = false,
  Optional[String] $repo_release                                 = undef,
  $passenger_package_ensure                                      = 'present',
  String[1] $passenger_package_name                              = 'passenger',
  $repo_source                                                   = undef,
  ### END Package Configuration ###

  ### START Service Configuation ###
  $service_ensure                                                = 'running',
  $service_enable                                                = true,
  $service_flags                                                 = undef,
  $service_restart                                               = undef,
  $service_name                                                  = 'nginx',
  $service_manage                                                = true,
  Boolean $service_config_check                                  = false,
  ### END Service Configuration ###

  ### START Hiera Lookups ###
  Hash $geo_mappings                                             = {},
  Hash $geo_mappings_defaults                                    = {},
  Hash $string_mappings                                          = {},
  Hash $string_mappings_defaults                                 = {},
  Hash $nginx_locations                                          = {},
  Hash $nginx_locations_defaults                                 = {},
  Hash $nginx_mailhosts                                          = {},
  Hash $nginx_mailhosts_defaults                                 = {},
  Hash $nginx_servers                                            = {},
  Hash $nginx_servers_defaults                                   = {},
  Hash $nginx_streamhosts                                        = {},
  Hash $nginx_streamhosts_defaults                               = {},
  Hash $nginx_upstreams                                          = {},
  $nginx_upstreams_defaults                                      = {},
  Boolean $purge_passenger_repo                                  = true,
  String[1] $nginx_version                                       = '1.6.0',

  ### END Hiera Lookups ###
) {
}
