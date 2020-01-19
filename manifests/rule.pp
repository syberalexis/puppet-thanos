# @summary This class manages rule service
#
# This class install Rule as service ruler evaluating Prometheus rules against given Query nodes,
#   exposing Store API and storing old blocks in bucket.
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
# @param grpc_address
#  Listen ip:port address for gRPC endpoints (StoreAPI). Make sure this address is routable from other components.
# @param grpc_grace_period
#  Time to wait after an interrupt received for GRPC Server.
# @param grpc_server_tls_cert
#  TLS Certificate for gRPC server, leave blank to disable TLS
# @param grpc_server_tls_key
#  TLS Key for the gRPC server, leave blank to disable TLS
# @param grpc_server_tls_client_ca
#  TLS CA to verify clients against. If no client CA is specified,
#    there is no client verification on server side. (tls.NoClientCert)
# @param labels
#  Labels to be applied to all generated metrics. Similar to external labels for Prometheus,
#    used to identify ruler and its blocks as unique source.
# @param data_dir
#  Data directory.
# @param rule_files
#  Rule files that should be used by rule manager. Can be in glob format.
# @param resend_delay
#  Minimum amount of time to wait before resending an alert to Alertmanager.
# @param eval_interval
#  The default evaluation interval to use.
# @param tsdb_block_duration
#  Block duration for TSDB block.
# @param tsdb_retention
#  Block retention time on local disk.
# @param alertmanagers_url
#  Alertmanager replica URLs to push firing alerts.
#    Ruler claims success if push to at least one alertmanager from discovered succeeds.
#    The scheme may be prefixed with 'dns+' or 'dnssrv+' to detect Alertmanager IPs through respective DNS lookups.
#    The port defaults to 9093 or the SRV record's value.
#    The URL path is used as a prefix for the regular Alertmanager API path.
# @param alertmanagers_send_timeout
#  Timeout for sending alerts to alertmanager
# @param alert_query_url
#  The external Thanos Query URL that would be set in all alerts 'Source' field
# @param alert_label_drop
#  Labels by name to drop before sending to alertmanager. This allows alert to be deduplicated on replica label.
#    Similar Prometheus alert relabelling
# @param web_route_prefix
#  Prefix for API and UI endpoints. This allows thanos UI to be served on a sub-path.
#    This option is analogous to --web.route-prefix of Prometheus.
# @param web_external_prefix
#  Static prefix for all HTML links and redirect URLs in the UI query web interface.
#    Actual endpoints are still served on / or the web.route-prefix.
#    This allows thanos UI to be served behind a reverse proxy that strips a URL sub-path.
# @param web_prefix_header
#  Name of HTTP request header used for dynamic prefixing of UI links and redirects.
#    This option is ignored if web.external-prefix argument is set.
#    Security risk: enable this option only if a reverse proxy in front of thanos is resetting the header.
#    The --web.prefix-header=X-Forwarded-Prefix option can be useful, for example,
#    if Thanos UI is served via Traefik reverse proxy with PathPrefixStrip option enabled, hich sends the stripped
#    prefix value in  X-Forwarded-Prefix header. This allows thanos UI to be served on a sub-path.
# @param objstore_config_file
#  Path to YAML file that contains object store configuration. See format details:
#    https://thanos.io/storage.md/#configuration
# @param queries
#  Addresses of statically configured query API servers. The scheme may be prefixed with 'dns+' or
#    'dnssrv+' to detect query API servers through respective DNS lookups.
# @param query_sd_files
#  Path to file that contain addresses of query peers. The path can be a glob pattern.
# @param query_sd_interval
#  Refresh interval to re-read file SD files. (used as a fallback)
# @param query_sd_dns_interval
#  Interval between DNS resolutions.
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
