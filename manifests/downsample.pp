# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
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
  Optional[Stdlib::Absolutepath]                  $objstore_config_file = undef,
) {
  assert_private()

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
