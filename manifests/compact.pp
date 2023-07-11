# @summary This class manages compact service
#
# This class install Compact as service to continuously compacts blocks in an object store bucket.
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
# @param wait_interval
#  Wait interval between consecutive compaction runs and bucket refreshes.
#    Only works when --wait flag specified.
# @param downsampling_disable
#  Disables downsampling. This is not recommended as querying long time ranges without non-downsampled data is
#    not efficient and useful e.g it is not possible to render all samples for a human eye anyway
# @param block_viewer_global_sync_block_interval
#  Repeat interval for syncing the blocks between local and remote view for /global Block Viewer UI.
# @param compact_concurrency
#  Number of goroutines to use when compacting groups.
# @param delete_delay
#  Time before a block marked for deletion is deleted from bucket.
#    If delete-delay is non zero, blocks will be marked for deletion and compactor component will
#    delete blocks marked for deletion from the bucket. If delete-delay is 0, blocks will be deleted straight away.
#    Note that deleting blocks immediately can cause query failures, if store gateway still has the block loaded,
#    or compactor is ignoring the deletion because it's compacting the block at the same time.
# @param selector_relabel_config_file
#  Path to YAML file that contains relabeling configuration that allows selecting blocks.
#    It follows native Prometheus relabel-config syntax.
#    See format details: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config
# @param web_external_prefix
#  Static prefix for all HTML links and redirect URLs in the bucket web UI interface.
#    Actual endpoints are still served on / or the web.route-prefix.
#    This allows thanos bucket web UI to be served behind a reverse proxy that strips a URL sub-path.
# @param web_prefix_header
#  Name of HTTP request header used for dynamic prefixing of UI links and redirects.
#    This option is ignored if web.external-prefix argument is set.
#    Security risk: enable this option only if a reverse proxy in front of thanos is resetting the header.
#    The --web.prefix-header=X-Forwarded-Prefix option can be useful, for example,
#    if Thanos UI is served via Traefik reverse proxy with PathPrefixStrip option enabled,
#    which sends the stripped prefix value in X-Forwarded-Prefix header. This allows thanos UI to be served on a sub-path.
# @param bucket_web_label
#  Prometheus label to use as timeline title in the bucket web UI
# @param extra_params
#  Parameters passed to the binary, ressently released in latest version of Thanos.
# @param env_vars
#  Environment variables passed during startup. Useful for example for ELASTIC_APM tracing integration.
# @example
#   include thanos::compact
class thanos::compact (
  Enum['present', 'absent']      $ensure                                  = 'present',
  String                         $user                                    = $thanos::user,
  String                         $group                                   = $thanos::group,
  Stdlib::Absolutepath           $bin_path                                = $thanos::bin_path,
  # Binary Parameters
  Thanos::Log_level              $log_level                               = 'info',
  Enum['logfmt', 'json']         $log_format                              = 'logfmt',
  Optional[Stdlib::Absolutepath] $tracing_config_file                     = $thanos::tracing_config_file,
  String                         $http_address                            = '0.0.0.0:10902',
  String                         $http_grace_period                       = '2m',
  Optional[Stdlib::Absolutepath] $data_dir                                = undef,
  Optional[Stdlib::Absolutepath] $objstore_config_file                    = $thanos::storage_config_file,
  String                         $consistency_delay                       = '30m',
  String                         $retention_resolution_raw                = '0d',
  String                         $retention_resolution_5m                 = '0d',
  String                         $retention_resolution_1h                 = '0d',
  Boolean                        $wait                                    = false,
  String                         $wait_interval                           = '5m',
  Boolean                        $downsampling_disable                    = false,
  String                         $block_viewer_global_sync_block_interval = '1m',
  Integer                        $compact_concurrency                     = 1,
  String                         $delete_delay                            = '48h',
  Optional[Stdlib::Absolutepath] $selector_relabel_config_file            = undef,
  Optional[String]               $web_external_prefix                     = undef,
  Optional[String]               $web_prefix_header                       = undef,
  Optional[String]               $bucket_web_label                        = undef,
  # Extra parametes
  Hash                           $extra_params                            = {},
  Array                          $env_vars                                = [],
) {
  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'compact':
    ensure       => $_service_ensure,
    bin_path     => $bin_path,
    user         => $user,
    group        => $group,
    params       => {
      'log.level'                               => $log_level,
      'log.format'                              => $log_format,
      'tracing.config-file'                     => $tracing_config_file,
      'http-address'                            => $http_address,
      'http-grace-period'                       => $http_grace_period,
      'data-dir'                                => $data_dir,
      'objstore.config-file'                    => $objstore_config_file,
      'consistency-delay'                       => $consistency_delay,
      'retention.resolution-raw'                => $retention_resolution_raw,
      'retention.resolution-5m'                 => $retention_resolution_5m,
      'retention.resolution-1h'                 => $retention_resolution_1h,
      'wait'                                    => $wait,
      'wait-interval'                           => $wait_interval,
      'downsampling.disable'                    => $downsampling_disable,
      'block-viewer.global.sync-block-interval' => $block_viewer_global_sync_block_interval,
      'compact.concurrency'                     => $compact_concurrency,
      'delete-delay'                            => $delete_delay,
      'selector.relabel-config-file'            => $selector_relabel_config_file,
      'web.external-prefix'                     => $web_external_prefix,
      'web.prefix-header'                       => $web_prefix_header,
      'bucket-web-label'                        => $bucket_web_label,
    },
    extra_params => $extra_params,
    env_vars     => $env_vars,
  }
}
