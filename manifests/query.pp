# @summary This class manages query service
#
# This class install Query as service query node exposing PromQL enabled Query API with data retrieved from multiple store nodes.
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
# @param grpc_client_tls_secure
#  Use TLS when talking to the gRPC server
# @param grpc_client_tls_cert
#  TLS Certificates to use to identify this client to the server
# @param grpc_client_tls_key
#  TLS Key for the client's certificate
# @param grpc_client_tls_ca
#  TLS CA Certificates to use to verify gRPC servers
# @param grpc_client_server_name
#  Server name to verify the hostname on the returned gRPC certificates. See https://tools.ietf.org/html/rfc4366#section-3.1
# @param web_route_prefix
#  Prefix for API and UI endpoints. This allows thanos UI to be served on a sub-path.
#    This option is analogous to --web.route-prefix of Promethus.
# @param web_external_prefix
#  Static prefix for all HTML links and redirect URLs in the UI query web interface.
#    Actual endpoints are still served on / or the web.route-prefix.
#    This allows thanos UI to be served behind a reverse proxy that strips a URL sub-path.
# @param web_prefix_header
#  Name of HTTP request header used for dynamic prefixing of UI links and redirects.
#    This option is ignored if web.external-prefix argument is set.
#    Security risk: enable this option only if a reverse proxy in front of thanos is resetting the header.
#    The --web.prefix-header=X-Forwarded-Prefix option can be useful, for example,
#    if Thanos UI is served via Traefik reverse proxy with PathPrefixStrip option enabled, which sends the stripped
#    prefix value in X-Forwarded-Prefix header. This allows thanos UI to be served on a sub-path.
# @param query_timeout
#  Maximum time to process query by query node.
# @param query_max_concurrent
#  Maximum number of queries processed concurrently by query node.
# @param query_replica_label
#  Labels to treat as a replica indicator along which data is deduplicated.
#    Still you will be able to query without deduplication using 'dedup=false' parameter.
# @param selector_labels
#  Query selector labels that will be exposed in info endpoint.
# @param stores
#  Addresses of statically configured store API servers. The scheme may be prefixed with 'dns+' or 'dnssrv+'
#    to detect store API servers through respective DNS lookups.
# @param store_sd_files
#  Path to files that contain addresses of store API servers. The path can be a glob pattern.
# @param store_sd_interval
#  Refresh interval to re-read file SD files. It is used as a resync fallback.
# @param store_sd_dns_interval
#  Interval between DNS resolutions.
# @param store_unhealthy_timeout
#  Timeout before an unhealthy store is cleaned from the store UI page.
# @param query_auto_downsampling
#  Enable automatic adjustment (step / 5) to what source of data should be used in store gateways
#    if no max_source_resolution param is specified.
# @param query_partial_response
#  Enable partial response for queries if no partial_response param is specified. --no-query.partial-response for disabling.
# @param query_default_evaluation_interval
#  Set default evaluation interval for sub queries.
# @param store_response_timeout
#  If a Store doesn't send any data in this specified duration then a Store will be ignored and partial data will be
#    returned if it's enabled. 0 disables timeout.
# @param extra_params
#  Parameters passed to the binary, ressently released in latest version of Thanos.
# @example
#   include thanos::query
class thanos::query (
  Enum['present', 'absent']      $ensure                            = 'present',
  String                         $user                              = $thanos::user,
  String                         $group                             = $thanos::group,
  Stdlib::Absolutepath           $bin_path                          = $thanos::bin_path,
  Thanos::Log_level              $log_level                         = 'info',
  Enum['logfmt', 'json']         $log_format                        = 'logfmt',
  Optional[Stdlib::Absolutepath] $tracing_config_file               = $thanos::tracing_config_file,
  String                         $http_address                      = '0.0.0.0:10902',
  String                         $http_grace_period                 = '2m',
  String                         $grpc_address                      = '0.0.0.0:10901',
  String                         $grpc_grace_period                 = '2m',
  Optional[Stdlib::Absolutepath] $grpc_server_tls_cert              = undef,
  Optional[Stdlib::Absolutepath] $grpc_server_tls_key               = undef,
  Optional[Stdlib::Absolutepath] $grpc_server_tls_client_ca         = undef,
  Boolean                        $grpc_client_tls_secure            = false,
  Optional[Stdlib::Absolutepath] $grpc_client_tls_cert              = undef,
  Optional[Stdlib::Absolutepath] $grpc_client_tls_key               = undef,
  Optional[Stdlib::Absolutepath] $grpc_client_tls_ca                = undef,
  Optional[String]               $grpc_client_server_name           = undef,
  Optional[String]               $web_route_prefix                  = undef,
  Optional[String]               $web_external_prefix               = undef,
  Optional[String]               $web_prefix_header                 = undef,
  String                         $query_timeout                     = '2m',
  Integer                        $query_max_concurrent              = 20,
  Optional[String]               $query_replica_label               = undef,
  Array[String]                  $selector_labels                   = [],
  Array[String]                  $stores                            = [],
  Array[Stdlib::Absolutepath]    $store_sd_files                    = [],
  String                         $store_sd_interval                 = '5m',
  String                         $store_sd_dns_interval             = '30s',
  String                         $store_unhealthy_timeout           = '30s',
  Boolean                        $query_auto_downsampling           = false,
  Boolean                        $query_partial_response            = false,
  String                         $query_default_evaluation_interval = '1m',
  String                         $store_response_timeout            = '0ms',
  Hash                           $extra_params                      = {},
) {
  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'query':
    ensure       => $_service_ensure,
    bin_path     => $bin_path,
    user         => $user,
    group        => $group,
    params       => {
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
    extra_params => $extra_params,
  }
}
