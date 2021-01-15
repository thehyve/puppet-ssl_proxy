node 'test.example.com' {
    include ::ssl_proxy

    ssl_proxy::host { 'test.example.com':
        dest => 'http://localhost:3000',
    }
}

node 'test2.example.com' {
    include ::ssl_proxy

    ssl_proxy::host { 'test2.example.com':
      dest => 'http://localhost:3002',
    }

    ssl_proxy::host { 'test3.example.com':
      dest => 'http://localhost:3003',
    }
}

node 'forward.example.com' {
    include ::ssl_proxy

    ssl_proxy::redirect { 'forward.example.com':
      target => 'https://test.example.com'
    }
}

node 'invalid-redirect.example.com' {
    include ::ssl_proxy

    ssl_proxy::redirect { 'forward.example.com':
      target => 'http://test.example.com'
    }
}
