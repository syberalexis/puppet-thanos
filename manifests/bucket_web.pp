# @summary This class manages bucket web interface service
#
# This class install Web interface for remote storage bucket.
#
# @param ensure
#  State ensured from compact service.
# @param user
#  User running thanos.
# @param group
#  Group under which thanos is running.
# @param bin_path
#  Path where binary is located.
# @param log_level
#  Only log messages with the given severity or above. One of: [debug, info, warn, error, fatal]
# @param log_format
#  Output format of log messages. One of: [logfmt, json]
# @param tracing_config_file
#  Path to YAML file with tracing configuration. See format details: https://thanos.io/tracing.md/#configuration
# @param objstore_config_file
#  Path to YAML file that contains object store configuration. See format details: https://thanos.io/storage.md/#configuration
# @param http_address
#  Listen host:port for HTTP endpoints.
# @param http_grace_period
#  Time to wait after an interrupt received for HTTP Server.
# @param web_external_prefix
#  Static prefix for all HTML links and redirect URLs in the bucket web UI interface.
#  Actual endpoints are still served on / or the web.route-prefix.
#  This allows thanos bucket web UI to be served behind a reverse proxy that strips a URL sub-path.
# @param web_prefix_header
#  Name of HTTP request header used for dynamic prefixing of UI links and redirects.
#  This option is ignored if web.external-prefix argument is set.
#  Security risk: enable this option only if a reverse proxy in front of thanos is resetting the header.
#  The --web.prefix-header=X-Forwarded-Prefix option can be useful, for example, if Thanos UI is served via Traefik
#    reverse proxy with PathPrefixStrip option enabled, which sends the stripped prefix value in X-Forwarded-Prefix header.
#  This allows thanos UI to be served on a sub-path.
# @param refresh
#  Refresh interval to download metadata from remote storage
# @param timeout
#  Timeout to download metadata from remote storage
# @param label
#  Prometheus label to use as timeline title
# @param extra_params
#  Parameters passed to the binary, ressently released in latest version of Thanos.
# @example
#   include thanos::bucket_web
class thanos::bucket_web (
  Enum['present', 'absent']      $ensure               = 'present',
  String                         $user                 = $thanos::user,
  String                         $group                = $thanos::group,
  Stdlib::Absolutepath           $bin_path             = $thanos::bin_path,
  Thanos::Log_level              $log_level            = 'info',
  Enum['logfmt', 'json']         $log_format           = 'logfmt',
  Optional[Stdlib::Absolutepath] $tracing_config_file  = $thanos::tracing_config_file,
  Optional[Stdlib::Absolutepath] $objstore_config_file = $thanos::storage_config_file,
  String                         $http_address         = '0.0.0.0:10902',
  String                         $http_grace_period    = '2m',
  String                         $web_external_prefix  = '',
  String                         $web_prefix_header    = '',
  String                         $refresh              = '30m',
  String                         $timeout              = '5m',
  String                         $label                = '',
  Hash                           $extra_params         = {},
) {
  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'bucket web':
    ensure       => $_service_ensure,
    bin_path     => $bin_path,
    user         => $user,
    group        => $group,
    params       => {
      'log.level'            => $log_level,
      'log.format'           => $log_format,
      'tracing.config-file'  => $tracing_config_file,
      'objstore.config-file' => $objstore_config_file,
      'http-address'         => $http_address,
      'http-grace-period'    => $http_grace_period,
      'web.external-prefix'  => $web_external_prefix,
      'web.prefix-header'    => $web_prefix_header,
      'refresh'              => $refresh,
      'timeout'              => $timeout,
      'label'                => $label,
    },
    extra_params => $extra_params,
  }
}
