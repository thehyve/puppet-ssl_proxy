define ssl_proxy::host (
  $servername          = $name,
  $dest                = 'http://localhost:8080/',
  $timeout             = '90s',
  $maintenance         = false,
  $maintenance_title   = 'Maintenance',
  $maintenance_message = 'This service is temporarily unavailable due to maintenance.',
  $service_down_title   = 'Service down',
  $service_down_message = 'This service is temporarily unavailable.',
) {
  $maintenance_root = "/var/www/maintenance/${servername}"
  file { $maintenance_root:
    ensure  => directory,
    require => File['/var/www/maintenance'],
  }
  -> file { "${maintenance_root}/502.html":
    ensure  => file,
    mode    => '0644',
    content => template('ssl_proxy/502.html.erb'),
  }
  -> file { "${maintenance_root}/503.html":
    ensure  => file,
    mode    => '0644',
    content => template('ssl_proxy/503.html.erb'),
  }
  if ($maintenance) {
    $default_return = {
      return => '503',
    }
    $error_pages = {
      '502' => '/502.html',
      '503' => '/503.html',
    }
    $maintenance_locations = {
      "${servername}/502" => {
        location => '= /502.html',
        internal => true,
        www_root => $maintenance_root,
      },
      "${servername}/503" => {
        location => '= /503.html',
        internal => true,
        www_root => $maintenance_root,
      },
    }
  } else {
    $default_return = undef
    $error_pages = {
      '502' => '/502.html',
    }
    $maintenance_locations = {
      "${servername}/502" => {
        location => '= /502.html',
        internal => true,
        www_root => $maintenance_root,
      },
    }
  }

  $www_root = "/var/www/letsencrypt/${servername}"
  file { $www_root:
    ensure  => directory,
    require => File['/var/www/letsencrypt'],
  }
  -> nginx::resource::server { "http:${servername}":
    ensure              => present,
    server_name         => [
      $servername
    ],
    listen_port         => 80,
    www_root            => $www_root,
    location_cfg_append => {
      'return' => '301 https://$server_name$request_uri'
    },
  }
  -> nginx::resource::location { "letsencrypt-${servername}":
    ensure   => present,
    server   => "http:${servername}",
    location => '/.well-known/acme-challenge/',
    www_root => $www_root,
    priority => 499,
  }
  -> letsencrypt::certonly { $servername:
    domains              => [
      $servername,
    ],
    plugin               => 'webroot',
    webroot_paths        => [
      $www_root,
    ],
    manage_cron          => true,
    pre_hook_commands    => [
      '/bin/systemctl reload nginx.service || /bin/systemctl start nginx.service'
    ],
    cron_success_command => '/bin/systemctl reload nginx.service',
  }
  -> nginx::resource::server { $servername:
    ensure                => present,
    listen_port           => 443,
    ssl                   => true,
    ssl_cert              => "/etc/letsencrypt/live/${servername}/fullchain.pem",
    ssl_key               => "/etc/letsencrypt/live/${servername}/privkey.pem",
    server_cfg_append     => {
      'add_header' => 'Strict-Transport-Security "max-age=63072000" always',
    },
    proxy                 => $dest,
    proxy_read_timeout    => $timeout,
    proxy_connect_timeout => $timeout,
    proxy_send_timeout    => $timeout,
    proxy_redirect        => 'default',
    location_cfg_prepend  => $default_return,
    error_pages           => $error_pages,
    locations             => $maintenance_locations,
    require               => File["${maintenance_root}/503.html"],
  }
}
