include ::ssl_proxy

ssl_proxy::redirect { 'forward.example.com':
  target => 'https://test.example.com',
}
