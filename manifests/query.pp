# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::query
class thanos::query (
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
  Boolean                                         $grpc_client_tls_secure            = false,
  Optional[Stdlib::Absolutepath]                  $grpc_client_tls_cert              = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_client_tls_key               = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_client_tls_ca                = undef,
  Optional[String]                                $grpc_client_server_name           = undef,
  Optional[String]                                $web_route_prefix                  = undef,
  Optional[String]                                $web_external_prefix               = undef,
  Optional[String]                                $web_prefix_header                 = undef,
  String                                          $query_timeout                     = '2m',
  Integer                                         $query_max_concurrent              = 20,
  Optional[String]                                $query_replica_label               = undef,
  Array[String]                                   $selector_labels                   = [],
  Array[String]                                   $stores                            = [],
  Array[Stdlib::Absolutepath]                     $store_sd_files                    = [],
  String                                          $store_sd_interval                 = '5m',
  String                                          $store_sd_dns_interval             = '30s',
  String                                          $store_unhealthy_timeout           = '30s',
  Boolean                                         $query_auto_downsampling           = false,
  Boolean                                         $query_partial_response            = false,
  String                                          $query_default_evaluation_interval = '1m',
  String                                          $store_response_timeout            = '0ms',
) {
  assert_private()

  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'query':
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
      'grpc-client-tls-secure'            => $grpc_client_tls_secure,
      'grpc-client-tls-cert'              => $grpc_client_tls_cert,
      'grpc-client-tls-key'               => $grpc_client_tls_key,
      'grpc-client-tls-ca'                => $grpc_client_tls_ca,
      'grpc-client-server-name'           => $grpc_client_server_name,
      'web.route-prefix'                  => $web_route_prefix,
      'web.external-prefix'               => $web_external_prefix,
      'web.prefix-header'                 => $web_prefix_header,
      'query.timeout'                     => $query_timeout,
      'query.max-concurrent'              => $query_max_concurrent,
      'query.replica-label'               => $query_replica_label,
      'selector-label'                    => $selector_labels,
      'store'                             => $stores,
      'store.sd-files'                    => $store_sd_files,
      'store.sd-interval'                 => $store_sd_interval,
      'store.sd-dns-interval'             => $store_sd_dns_interval,
      'store.unhealthy-timeout'           => $store_unhealthy_timeout,
      'query.auto-downsampling'           => $query_auto_downsampling,
      'query.partial-response'            => $query_partial_response,
      'query.default-evaluation-interval' => $query_default_evaluation_interval,
      'store.response-timeout'            => $store_response_timeout,
    },
  }
}
