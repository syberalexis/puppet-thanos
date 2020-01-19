# @summary This class manages compact service
#
# This class install Compact as service to continuously compacts blocks in an object store bucket.
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
#  Data directory in which to cache blocks and process compactions.
# @param objstore_config_file
#  Path to YAML file that contains object store configuration. See format details: https://thanos.io/storage.md/#configuration
# @param consistency_delay
#  Minimum age of fresh (non-compacted) blocks before they are being processed.
#    Malformed blocks older than the maximum of consistency-delay and 30m0s will be removed.
# @param retention_resolution_raw
#  How long to retain raw samples in bucket. 0d - disables this retention
# @param retention_resolution_5m
#  How long to retain samples of resolution 1 (5 minutes) in bucket. 0d - disables this retention
# @param retention_resolution_1h
#  How long to retain samples of resolution 2 (1 hour) in bucket. 0d - disables this retention
# @param wait
#  Do not exit after all compactions have been processed and wait for new work.
# @param downsampling_disable
#  Disables downsampling. This is not recommended as querying long time ranges without non-downsampled data is
#    not efficient and useful e.g it is not possible to render all samples for a human eye anyway
# @param block_sync_concurrency
#  Number of goroutines to use when syncing block metadata from object storage.
# @param compact_concurrency
#  Number of goroutines to use when compacting groups.
# @param selector_relabel_config_file
#  Path to YAML file that contains relabeling configuration that allows selecting blocks.
#    It follows native Prometheus relabel-config syntax.
#    See format details: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config
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
  Boolean                                         $downsampling_disable         = false,
  Integer                                         $block_sync_concurrency       = 20,
  Integer                                         $compact_concurrency          = 1,
  Optional[Stdlib::Absolutepath]                  $selector_relabel_config_file = undef,
) {
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
      'downsampling.disable'         => $downsampling_disable,
      'block-sync-concurrency'       => $block_sync_concurrency,
      'compact.concurrency'          => $compact_concurrency,
      'selector.relabel-config-file' => $selector_relabel_config_file,
    },
  }
}
