node 'test.example.com' {
    include ::ssl_proxy

    ssl_proxy::host { 'test.example.com':
        dest => 'http://localhost:3000',
    }
}
