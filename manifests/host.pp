define ssl_proxy::host (
  $servername = $name,
  $dest       = 'http://localhost:8080/',
  $timeout    = '90s',
) {
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
    location => '/.well-known',
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
    manage_cron          => false, # true,
    cron_success_command => '/bin/systemctl reload nginx.service',
  }
  -> nginx::resource::server { $servername:
    ensure                => present,
    listen_port           => 443,
    ssl                   => true,
    ssl_cert              => "/etc/letsencrypt/live/${servername}/fullchain.pem",
    ssl_key               => "/etc/letsencrypt/live/${servername}/privkey.pem",
    proxy                 => $dest,
    proxy_read_timeout    => $timeout,
    proxy_connect_timeout => $timeout,
    proxy_send_timeout    => $timeout,
    proxy_redirect        => 'default'
  }
}
