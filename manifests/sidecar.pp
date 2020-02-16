# @summary This class manages sidecar service
#
# This class install Sidecar as service sidecar for Prometheus server.
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
# @param grpc_address
#  Listen ip:port address for gRPC endpoints (StoreAPI). Make sure this address is routable from other components.
# @param grpc_grace_period
#  Time to wait after an interrupt received for GRPC Server.
# @param grpc_server_tls_cert
#  TLS Certificate for gRPC server, leave blank to disable TLS
# @param grpc_server_tls_key
#  TLS Key for the gRPC server, leave blank to disable TLS
# @param grpc_server_tls_client_ca
#  TLS CA to verify clients against. If no client CA is specified, there is no client verification on server side. (tls.NoClientCert)
# @param prometheus_url
#  URL at which to reach Prometheus's API. For better performance use local network.
# @param prometheus_ready_timeout
#  Maximum time to wait for the Prometheus instance to start up
# @param tsdb_path
#  Data directory of TSDB.
# @param reloader_config_file
#  Config file watched by the reloader.
# @param reloader_config_envsubst_file
#  Output file for environment variable substituted config file.
# @param reloader_rule_dirs
#  Rule directories for the reloader to refresh.
# @param objstore_config_file
#  Path to YAML file that contains object store configuration. See format details: https://thanos.io/storage.md/#configuration
# @param min_time
#  Start of time range limit to serve. Thanos sidecar will serve only metrics, which happened later than this value.
#    Option can be a constant time in RFC3339 format or time duration relative to current time, such as -1d or 2h45m. Valid
#    duration units are ms, s, m, h, d, w, y.
# @example
#   include thanos::sidecar
class thanos::sidecar (
  Enum['present', 'absent']                       $ensure                        = 'present',
  String                                          $user                          = $thanos::user,
  String                                          $group                         = $thanos::group,
  Stdlib::Absolutepath                            $bin_path                      = $thanos::bin_path,
  Enum['debug', 'info', 'warn', 'error', 'fatal'] $log_level                     = 'info',
  Enum['logfmt', 'json']                          $log_format                    = 'logfmt',
  Optional[Stdlib::Absolutepath]                  $tracing_config_file           = $thanos::tracing_config_file,
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
  Optional[String]                                $min_time                      = undef,
) {
  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'sidecar':
    ensure   => $_service_ensure,
    bin_path => $bin_path,
    user     => $user,
    group    => $group,
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
