# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::compact
class thanos::compact (
  Enum['present', 'absent']                       $ensure                       = 'present',
  Stdlib::Absolutepath                            $bin_path                     = $thanos::bin_path,
  Enum['debug', 'info', 'warn', 'error', 'fatal'] $log_level                    = 'info',
  Enum['logfmt', 'json']                          $log_format                   = 'logfmt',
  Optional[Stdlib::Absolutepath]                  $tracing_config_file          = undef,
  String                                          $http_address                 = '0.0.0.0:10902',
  String                                          $http_grace_period            = '2m',
  Optional[Stdlib::Absolutepath]                  $data_dir                     = undef,
  Optional[Stdlib::Absolutepath]                  $objstore_config_file         = undef,
  String                                          $consistency_delay            = '30m',
  String                                          $retention_resolution_raw     = '0d',
  String                                          $retention_resolution_5m      = '0d',
  String                                          $retention_resolution_1h      = '0d',
  Boolean                                         $wait                         = false,
  Integer                                         $block_sync_concurrency       = 20,
  Integer                                         $compact_concurrency          = 1,
  Optional[Stdlib::Absolutepath]                  $selector_relabel_config_file = undef,
) {
  assert_private()

  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'compact':
    ensure   => $_service_ensure,
    bin_path => $bin_path,
    params   => {
      'log.level'                    => $log_level,
      'log.format'                   => $log_format,
      'tracing.config-file'          => $tracing_config_file,
      'http-address'                 => $http_address,
      'http-grace-period'            => $http_grace_period,
      'data-dir'                     => $data_dir,
      'objstore.config-file'         => $objstore_config_file,
      'consistency-delay'            => $consistency_delay,
      'retention.resolution-raw'     => $retention_resolution_raw,
      'retention.resolution-5m'      => $retention_resolution_5m,
      'retention.resolution-1h'      => $retention_resolution_1h,
      'wait'                         => $wait,
      'block-sync-concurrency'       => $block_sync_concurrency,
      'compact.concurrency'          => $compact_concurrency,
      'selector.relabel-config-file' => $selector_relabel_config_file,
    },
  }
}
