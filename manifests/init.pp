# Class: ssl_proxy
# ===========================
#
# Provides a secure proxy.
#
# Parameters
# ----------
#
# * `dest`
#  Proxy target
#
# * `timeout`
#  Proxy timeout
#
# Examples
# --------
#
# @example
#    include ::ssl_proxy
#
#    ssl_proxy::host { 'example.com':
#      dest => 'http://localhost:3000',
#    }
#
# Authors
# -------
#
# Gijs Kant <gijs@thehyve.nl>
#
# Copyright
# ---------
#
# Copyright 2021 The Hyve
#
class ssl_proxy {
  if !defined(Class['nginx']) {
    include ::nginx
  }
  if !defined(Class['letsencrypt']) {
    include ::letsencrypt
  }
}
