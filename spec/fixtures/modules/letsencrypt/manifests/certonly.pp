# @summary Request a certificate using the `certonly` installer
#
# This type can be used to request a certificate using the `certonly` installer.
#
# @param ensure
#   Intended state of the resource
#   Will remove certificates for specified domains if set to 'absent'. Will
#   also remove cronjobs and renewal scripts if `manage_cron` is set to 'true'.
# @param domains
#   An array of domains to include in the CSR.
# @param custom_plugin Whether to use a custom plugin in additional_args and disable -a flag.
# @param plugin The authenticator plugin to use when requesting the certificate.
# @param webroot_paths
#   An array of webroot paths for the domains in `domains`.
#   Required if using `plugin => 'webroot'`. If `domains` and
#   `webroot_paths` are not the same length, the last `webroot_paths`
#   element will be used for all subsequent domains.
# @param letsencrypt_command Command to run letsencrypt
# @param additional_args An array of additional command line arguments to pass to the `letsencrypt-auto` command.
# @param environment  An optional array of environment variables (in addition to VENV_PATH).
# @param key_size Size for the RSA public key
# @param manage_cron
#   Indicating whether or not to schedule cron job for renewal.
#   Runs daily but only renews if near expiration, e.g. within 10 days.
# @param suppress_cron_output Redirect cron output to devnull
# @param cron_before_command Representation of a command that should be run before renewal command
# @param cron_success_command Representation of a command that should be run if the renewal command succeeds.
# @param cron_hour
#   Optional hour(s) that the renewal command should execute.
#   e.g. '[0,12]' execute at midnight and midday.  Default - seeded random hour.
# @param cron_minute
#   Optional minute(s) that the renewal command should execute.
#   e.g. 0 or '00' or [0,30].  Default - seeded random minute.
# @param cron_monthday
#   Optional string, integer or array of monthday(s) the renewal command should
#   run. E.g. '2-30/2' to run on even days. Default: Every day.
# @param config_dir The path to the configuration directory.
# @param pre_hook_commands Array of commands to run in a shell before attempting to obtain/renew the certificate.
# @param post_hook_commands Array of command(s) to run in a shell after attempting to obtain/renew the certificate.
# @param deploy_hook_commands
#   Array of command(s) to run in a shell once if the certificate is successfully issued.
#   Two environmental variables are supplied by certbot:
#   - $RENEWED_LINEAGE: Points to the live directory with the cert files and key.
#                       Example: /etc/letsencrypt/live/example.com
#   - $RENEWED_DOMAINS: A space-delimited list of renewed certificate domains.
#                       Example: "example.com www.example.com"
#
define letsencrypt::certonly (
  Enum['present', 'absent']                  $ensure              = 'present',
  Array[String[1]]                          $domains              = [$title],
  String[1]                                 $cert_name            = $title,
  Boolean                                   $custom_plugin        = false,
  $plugin                                                         = 'standalone',
  Array[String[1]]                          $webroot_paths               = [],
  String[1]                                 $letsencrypt_command  = 'certbot',
  Integer[2048]                             $key_size             = 4096,
  Array[String[1]]                          $additional_args      = [],
  Array[String[1]]                          $environment          = [],
  Boolean                                   $manage_cron          = false,
  Boolean                                   $suppress_cron_output = false,
  Optional[String[1]]                       $cron_before_command  = undef,
  Optional[String[1]]                       $cron_success_command = undef,
  Array[Variant[Integer[0, 59], String[1]]] $cron_monthday        = ['*'],
  Variant[Integer[0, 23], String, Array]     $cron_hour           = 4,
  Variant[Integer[0, 59], String, Array]     $cron_minute         = 12,
  $config_dir                                                     = '/etc/letsencrypt',
  Variant[String[1], Array[String[1]]]      $pre_hook_commands    = [],
  Variant[String[1], Array[String[1]]]      $post_hook_commands   = [],
  Variant[String[1], Array[String[1]]]      $deploy_hook_commands = [],
) {
  if $plugin == 'webroot' and empty($webroot_paths) {
    fail("The 'webroot_paths' parameter must be specified when using the 'webroot' plugin")
  }
}
