# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::rule
class thanos::rule (
  Enum['present', 'absent']                       $ensure                     = 'present',
  Stdlib::Absolutepath                            $bin_path                   = $thanos::bin_path,
  Enum['debug', 'info', 'warn', 'error', 'fatal'] $log_level                  = 'info',
  Enum['logfmt', 'json']                          $log_format                 = 'logfmt',
  Optional[Stdlib::Absolutepath]                  $tracing_config_file        = undef,
  String                                          $http_address               = '0.0.0.0:10902',
  String                                          $http_grace_period          = '2m',
  String                                          $grpc_address               = '0.0.0.0:10901',
  String                                          $grpc_grace_period          = '2m',
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_cert       = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_key        = undef,
  Optional[Stdlib::Absolutepath]                  $grpc_server_tls_client_ca  = undef,
  Array[String]                                   $labels                     = [],
  Optional[Stdlib::Absolutepath]                  $data_dir                   = undef,
  Array[Stdlib::Absolutepath]                     $rule_files                 = [],
  String                                          $resend_delay               = '1m',
  String                                          $eval_interval              = '30s',
  String                                          $tsdb_block_duration        = '2h',
  String                                          $tsdb_retention             = '48h',
  Array[Stdlib::HTTPUrl]                          $alertmanagers_url          = [],
  String                                          $alertmanagers_send_timeout = '10s',
  Optional[Stdlib::HTTPUrl]                       $alert_query_url            = undef,
  Array[String]                                   $alert_label_drop           = [],
  Optional[String]                                $web_route_prefix           = undef,
  Optional[String]                                $web_external_prefix        = undef,
  Optional[String]                                $web_prefix_header          = undef,
  Optional[Stdlib::Absolutepath]                  $objstore_config_file       = undef,
  Array[String]                                   $queries                    = [],
  Array[Stdlib::Absolutepath]                     $query_sd_files             = [],
  String                                          $query_sd_interval          = '5m',
  String                                          $query_sd_dns_interval      = '30s',
) {
  assert_private()

  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'rule':
    ensure   => $_service_ensure,
    bin_path => $bin_path,
    params   => {
      'log.level'                  => $log_level,
      'log.format'                 => $log_format,
      'tracing.config-file'        => $tracing_config_file,
      'http-address'               => $http_address,
      'http-grace-period'          => $http_grace_period,
      'grpc-address'               => $grpc_address,
      'grpc-grace-period'          => $grpc_grace_period,
      'grpc-server-tls-cert'       => $grpc_server_tls_cert,
      'grpc-server-tls-key'        => $grpc_server_tls_key,
      'grpc-server-tls-client-ca'  => $grpc_server_tls_client_ca,
      'label'                      => $labels,
      'data-dir'                   => $data_dir,
      'rule-file'                  => $rule_files,
      'resend-delay'               => $resend_delay,
      'eval-interval'              => $eval_interval,
      'tsdb.block-duration'        => $tsdb_block_duration,
      'tsdb.retention'             => $tsdb_retention,
      'alertmanagers.url'          => $alertmanagers_url,
      'alertmanagers.send-timeout' => $alertmanagers_send_timeout,
      'alert.query-url'            => $alert_query_url,
      'alert.label-drop'           => $alert_label_drop,
      'web.route-prefix'           => $web_route_prefix,
      'web.external-prefix'        => $web_external_prefix,
      'web.prefix-header'          => $web_prefix_header,
      'objstore.config-file'       => $objstore_config_file,
      'query'                      => $queries,
      'query.sd-files'             => $query_sd_files,
      'query.sd-interval'          => $query_sd_interval,
      'query.sd-dns-interval'      => $query_sd_dns_interval,
    },
  }
}
