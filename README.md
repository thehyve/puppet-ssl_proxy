# Puppet module providing an SSL proxy

[![Build Status](https://travis-ci.com/thehyve/puppet-ssl_proxy.svg?branch=main)](https://travis-ci.com/thehyve/puppet-ssl_proxy/branches)

This module provides an SSL proxy using nginx and Let's Encrypt.


## Dependencies and installation

### Install Puppet
```bash
# Install Puppet
apt install puppet

# Check Puppet version, Puppet 4.8 and Puppet 5 should be fine.
puppet --version
```

### Puppet modules
The module depends on the `stdlib`, `nginx` and `letsencrypt` modules.

The most convenient way is to run `puppet module install` as `root`:
```bash
sudo puppet module install puppetlabs-stdlib
sudo puppet module install puppet-nginx --version 2.1.1
sudo puppet module install puppet-letsencrypt --version 6.0.0
```

Check the installed modules:
```bash
sudo puppet module list --tree
```

### Install the `ssl_proxy` module
Copy the `podium` module repository to the `/etc/puppetlabs/code/modules` directory:
```bash
cd /etc/puppetlabs/code/modules
git clone https://github.com/thehyve/puppet-ssl_proxy.git ssl_proxy
```


## Configuration

### TLS configuration

The module uses `nginx` and `letsencrypt` for the proxy. 
Please ensure that the configuration is secure. 
It is preferred to configure good defaults in the `common.yaml`
file of each environment:
```yaml
nginx::ssl_protocols: TLSv1.2 TLSv1.3
nginx::ssl_ciphers: ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
nginx::ssl_prefer_server_ciphers: 'off'
nginx::proxy_set_header:
  - X-Real-IP $remote_addr
  - X-Forwarded-For $proxy_add_x_forwarded_for
  - X-Forwarded-Proto $scheme
  - Proxy ""
letsencrypt::email: <support email address>
```
Please update the protocol and cipher lists to reflect the advice from the [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/#server=nginx&config=intermediate).
To check if the configuration is secure, check, e.g.,
the [SSL Labs server report for repo.thehyve.nl](https://www.ssllabs.com/analyze.html?d=repo.thehyve.nl&latest).

This proxy header configuration works well for most applications. Some also need the `Host $host` header (e.g., Keycloak). This configuration can be overridden in the machine specific Hiera file.

### The node manifest

#### Create a reverse proxy with `ssl_proxy::host`

Here is an example manifest file `manifests/test.example.com.pp`:
```puppet
node 'test.example.com' {
  include ::ssl_proxy

  ssl_proxy::host { 'test.example.com':
    servername => 'test.example.com',
    dest       => 'http://test:8080',
  }
}
```
The node manifest can also be in another file, e.g., `site.pp`.

#### Create a redirect with `ssl_proxy::redirect`

Here is an example manifest file `manifests/forward.example.com.pp`:
```puppet
node 'test.example.com' {
  include ::ssl_proxy

  # Forward requests to forward.example.com to test.example.com.
  # Target should start with 'https://'
  ssl_proxy::host { 'forward.example.com':
    servername => 'test.example.com',
    target     => 'https://test.example.com',
  }
}
```

### Configuring a node using Hiera

It is preferred to configure the module parameters using Hiera.

To activate the use of Hiera, configure `/etc/puppetlabs/code/hiera.yaml`. Example:
```yaml
---
:backends:
  - yaml
:yaml:
  :datadir: '/etc/puppetlabs/code/hieradata'
:hierarchy:
  - '%{::clientcert}'
  - 'default'
```
Defaults can then be configured in `/etc/puppetlabs/code/hieradata/default.yaml`, e.g.:
```yaml
---
# Configuration based on https://ssl-config.mozilla.org/
# Please review regularly
nginx::ssl_protocols: TLSv1.2 TLSv1.3
nginx::ssl_ciphers: ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
nginx::ssl_prefer_server_ciphers: 'off'
nginx::proxy_set_header:
  - X-Real-IP $remote_addr
  - X-Forwarded-For $proxy_add_x_forwarded_for
  - X-Forwarded-Proto $scheme
  - Proxy ""

letsencrypt::email: letsencrypt@example.com
letsencrypt::configure_epel: false
```

For Keycloak it is required to use also set the `Host` header:
```yaml
nginx::proxy_set_header:
  - Host $host
  - X-Real-IP $remote_addr
  - X-Forwarded-For $proxy_add_x_forwarded_for
  - X-Forwarded-Proto $scheme
  - Proxy ""
```

`TODO`: Find out if the `Host` header can be added by default, or how to make this configurable.

Machine specific configuration should be in `/etc/puppetlabs/code/hieradata/${hostname}.yaml`, e.g.,
`/etc/puppetlabs/code/hieradata/test.example.com.yaml`:
```yaml
# Configure Let's Encrypt staging server for testing
letsencrypt::config:
  server: https://acme-staging-v02.api.letsencrypt.org/directory
```

## Masterless installation
It is also possible to use the module without a Puppet master by applying a manifest directly using `puppet apply`.

There is an example manifest in `examples/host.pp`.

```bash
cd /etc/puppetlabes/code/modules/ssl_proxy
sudo puppet apply examples/host.pp
```


## Development

### Test
There are some automated tests, run using [rake].

`ruby >= 2.3` is required. [rvm] can be used to install a specific version of `ruby`.
Use `rvm install 2.4` to use `ruby` version `2.4`.


#### Rake tests
Install rake using the system-wide `ruby`:
```bash
yum install ruby-devel
gem install bundler
export PUPPET_VERSION=5.5.1
bundle
```
or using `rvm`:
```bash
rvm install 2.4
gem install bundler
export PUPPET_VERSION=5.5.1
bundle
```
Run the test suite:
```bash
rake test
```

### Resources

Overview of the resources defined in this module.

| Resource name       | Description |
|:------------------- |:----------- |
| `::ssl_proxy::host` | Creates a proxy for a hostname and ensures the presence of a valid SSL certificate. |

#### Resource parameters

Overview of the parameters that can be used to configure the `host` resource.

| Parameter              | Default value           | Description |
|:---------------------- |:----------------------- |:----------- |
| `servername`           |                         | The external servername. |
| `dest`                 | `http://localhost:8080` | The address the proxy forwards to. |
| `allow`                | `[]`                    | IP addresses to allow traffic from.
| `timeout`              | `90s`                   | The proxy timeout. |
| `maintenance`          | `false`                 | Enables the maintenance page. |
| `maintenance_title`    | `Maintenance`           | Title of the maintenance page. |
| `maintenance_message`  | `This service is temporarily unavailable due to maintenance.` | Maintenance page message. |
| `service_down_title`   | `Service down`          | Title of the 503 (Service Unavailable) page. |
| `service_down_message` | `This service is temporarily unavailable.` | Message on the 503 (Service Unavailable) page. |


## License

Copyright &copy; 2021 &nbsp; The Hyve and respective contributors.

Licensed under the [Apache License, Version 2.0](LICENSE) (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


[rake]: https://github.com/ruby/rake
[rvm]: https://rvm.io/
