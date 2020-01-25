# @summary This class manages downsample service
#
# This class install Downsample as service continuously downsamples blocks in an object store bucket.
#
# @param ensure
#  State ensured from compact service.
# @param bin_path
#  Path where binary is located.
# @param log_level
#  Only log messages with the given severity or above. One of: [debug, info, warn, error, fatal]
# @param log_format
#  Output format of log messages. One of: [logfmt, json]
# @param tracing_config_file
#  Path to YAML file with tracing configuration. See format details: https://thanos.io/tracing.md/#configuration
# @param http_address
#  Listen host:port for HTTP endpoints.
# @param http_grace_period
#  Time to wait after an interrupt received for HTTP Server.
# @param data_dir
#  Data directory in which to cache blocks and process downsamplings.
# @param objstore_config_file
#  Path to YAML file that contains object store configuration. See format details: https://thanos.io/storage.md/#configuration
# @example
#   include thanos::downsample
class thanos::downsample (
  Enum['present', 'absent']                       $ensure               = 'present',
  Stdlib::Absolutepath                            $bin_path             = $thanos::bin_path,
  Enum['debug', 'info', 'warn', 'error', 'fatal'] $log_level            = 'info',
  Enum['logfmt', 'json']                          $log_format           = 'logfmt',
  Optional[Stdlib::Absolutepath]                  $tracing_config_file  = undef,
  String                                          $http_address         = '0.0.0.0:10902',
  String                                          $http_grace_period    = '2m',
  Optional[Stdlib::Absolutepath]                  $data_dir             = undef,
  Optional[Stdlib::Absolutepath]                  $objstore_config_file = $thanos::objstore_config_file,
) {
  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'downsample':
    ensure   => $_service_ensure,
    bin_path => $bin_path,
    params   => {
      'log.level'            => $log_level,
      'log.format'           => $log_format,
      'tracing.config-file'  => $tracing_config_file,
      'http-address'         => $http_address,
      'http-grace-period'    => $http_grace_period,
      'data-dir'             => $data_dir,
      'objstore.config-file' => $objstore_config_file,
    },
  }
}
