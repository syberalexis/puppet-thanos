# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::store
class thanos::store (
  Enum['present', 'absent']                       $ensure                            = 'present',
  Stdlib::Absolutepath                            $bin_path                          = $thanos::bin_path,
  Enum['debug', 'info', 'warn', 'error', 'fatal'] $log_level                         = 'info',
  Enum['logfmt', 'json']                          $log_format                        = 'logfmt',
  Optional[Stdlib::Absolutepath]                  $tracing_config_file               = undef,
  String                                          $http_address                      = '0.0.0.0:10902',
  String                                          $http_grace_period                 = '2m',
  String                                          $grpc_address                      = '0.0.0.0:10901',
  String                                          $grpc_grace_period                 = '2m',
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_cert              = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_key               = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_client_ca         = undef,
  Optional[Stdlib::Absolutepath]                  $data_dir                          = undef,
  String                                          $index_cache_size                  = '250MB',
  String                                          $chunck_pool_size                  = '2GB',
  Integer                                         $store_grpc_series_sample_limit    = 0,
  Integer                                         $store_grpc_series_max_concurrency = 20,
  Optional[Stdlib::Absolutepath]                  $objstore_config_file              = undef,
  String                                          $sync_block_duration               = '3m',
  Integer                                         $block_sync_concurrency            = 20,
  String                                          $min_time                          = '0000-01-01T00:00:00Z',
  String                                          $max_time                          = '0000-01-01T00:00:00Z',
  Optional[Stdlib::Absolutepath]                  $selector_relabel_config_file      = undef,
) {
  assert_private()

  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'store':
    ensure   => $_service_ensure,
    bin_path => $bin_path,
    params   => {
      'log.level'                         => $log_level,
      'log.format'                        => $log_format,
      'tracing.config-file'               => $tracing_config_file,
      'http-address'                      => $http_address,
      'http-grace-period'                 => $http_grace_period,
      'grpc-address'                      => $grpc_address,
      'grpc-grace-period'                 => $grpc_grace_period,
      'grpc-server-tls-cert'              => $grpc_server_tls_cert,
      'grpc-server-tls-key'               => $grpc_server_tls_key,
      'grpc-server-tls-client-ca'         => $grpc_server_tls_client_ca,
      'data-dir'                          => $data_dir,
      'index-cache-size'                  => $index_cache_size,
      'chunk-pool-size'                   => $chunck_pool_size,
      'store.grpc.series-sample-limit'    => $store_grpc_series_sample_limit,
      'store.grpc.series-max-concurrency' => $store_grpc_series_max_concurrency,
      'objstore.config-file'              => $objstore_config_file,
      'sync-block-duration'               => $sync_block_duration,
      'block-sync-concurrency'            => $block_sync_concurrency,
      'min-time'                          => $min_time,
      'max-time'                          => $max_time,
      'selector.relabel-config-file'      => $selector_relabel_config_file,
    },
  }
}
