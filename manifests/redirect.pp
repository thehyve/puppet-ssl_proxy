define ssl_proxy::redirect (
  String[1] $target,
  $servername = $name,
) {
  if $target !~ /^https:\/\// {
    fail("The redirect target should start with 'https://'. Unexpected target: ${target}")
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
      'return' => "301 ${target}\$request_uri"
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
    ensure              => present,
    listen_port         => 443,
    ssl                 => true,
    ssl_cert            => "/etc/letsencrypt/live/${servername}/fullchain.pem",
    ssl_key             => "/etc/letsencrypt/live/${servername}/privkey.pem",
    server_cfg_append   => {
      'add_header' => 'Strict-Transport-Security "max-age=63072000" always',
    },
    location_cfg_append => {
      'return' => "301 ${target}\$request_uri"
    },
  }
}
