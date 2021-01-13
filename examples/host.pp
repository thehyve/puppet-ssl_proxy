include ::ssl_proxy

ssl_proxy::host { 'example.com':
  dest => 'http://localhost:3000',
}
