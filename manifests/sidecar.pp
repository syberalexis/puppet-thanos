# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::sidecar
class thanos::sidecar (
  Enum['present', 'absent']                       $ensure                        = 'present',
  Stdlib::Absolutepath                            $bin_path                      = $thanos::bin_path,
  Enum['debug', 'info', 'warn', 'error', 'fatal'] $log_level                     = 'info',
  Enum['logfmt', 'json']                          $log_format                    = 'logfmt',
  Optional[Stdlib::Absolutepath]                  $tracing_config_file           = undef,
  String                                          $http_address                  = '0.0.0.0:10902',
  String                                          $http_grace_period             = '2m',
  String                                          $grpc_address                  = '0.0.0.0:10901',
  String                                          $grpc_grace_period             = '2m',
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_cert          = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_key           = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_client_ca     = undef,
  Stdlib::HTTPUrl                                 $prometheus_url                = 'http://localhost:9090',
  String                                          $prometheus_ready_timeout      = '10m',
  Stdlib::Absolutepath                            $tsdb_path                     = $thanos::tsdb_path,
  Optional[Stdlib::Absolutepath]                  $reloader_config_file          = undef,
  Optional[Stdlib::Absolutepath]                  $reloader_config_envsubst_file = undef,
  Array[Stdlib::Absolutepath]                     $reloader_rule_dirs            = [],
  Optional[Stdlib::Absolutepath]                  $objstore_config_file          = undef,
  String                                          $min_time                      = '0000-01-01T00:00:00Z'
) {
  assert_private()

  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'sidecar':
    ensure   => $_service_ensure,
    bin_path => $bin_path,
    params   => {
      'log.level'                     => $log_level,
      'log.format'                    => $log_format,
      'tracing.config-file'           => $tracing_config_file,
      'http-address'                  => $http_address,
      'http-grace-period'             => $http_grace_period,
      'grpc-address'                  => $grpc_address,
      'grpc-grace-period'             => $grpc_grace_period,
      'grpc-server-tls-cert'          => $grpc_server_tls_cert,
      'grpc-server-tls-key'           => $grpc_server_tls_key,
      'grpc-server-tls-client-ca'     => $grpc_server_tls_client_ca,
      'prometheus.url'                => $prometheus_url,
      'prometheus.ready_timeout'      => $prometheus_ready_timeout,
      'tsdb.path'                     => $tsdb_path,
      'reloader.config-file'          => $reloader_config_file,
      'reloader.config-envsubst-file' => $reloader_config_envsubst_file,
      'reloader.rule-dir'             => $reloader_rule_dirs,
      'objstore.config-file'          => $objstore_config_file,
      'min-time'                      => $min_time,
    },
  }
}
