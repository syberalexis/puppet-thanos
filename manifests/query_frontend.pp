# @summary This class manages query frontend service
#
# This class install Query Frontend as service that can be put in front of Thanos Queriers to improve the read path.
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
# @param query_range_split_interval
#  Split queries by an interval and execute in parallel, 0 disables it.
# @param query_range_max_retries_per_request
#  Maximum number of retries for a single request; beyond this, the downstream error is returned.
# @param query_range_max_query_length
#  Limit the query time range (end - start time) in the query-frontend, 0 disables it.
# @param query_range_max_query_parrallelism
#  Maximum number of queries will be scheduled in parallel by the frontend.
# @param query_range_response_cache_max_freshness
#  Most recent allowed cacheable result, to prevent caching very recent results that might still be in flux.
# @param query_range_partial_response
#  Enable partial response for queries if no partial_response param is specified. --no-query-range.partial-response for disabling.
# @param query_range_response_cache_config_file
#  Path to YAML file that contains response cache configuration.
# @param http_address
#  Listen host:port for HTTP endpoints.
# @param http_grace_period
#  Time to wait after an interrupt received for HTTP Server.
# @param query_frontend_downstream_url
#  URL of downstream Prometheus Query compatible API.
# @param query_frontend_compress_responses
#  Compress HTTP responses.
# @param query_frontend_log_queries_longer_than
#  Log queries that are slower than the specified duration. Set to 0 to disable. Set to < 0 to enable on all queries.
# @param log_request_decision
#  Request Logging for logging the start and end of requests. LogFinishCall is enabled by default.
#    LogFinishCall : Logs the finish call of the requests.
#    LogStartAndFinishCall : Logs the start and finish call of the requests.
#    NoLogCall : Disable request logging.
# @param max_open_files
#  Define how many open files the service is able to use
#  In some cases, the default value (1024) needs to be increased
# @param extra_params
#  Parameters passed to the binary, ressently released in latest version of Thanos.
# @example
#   include thanos::query
class thanos::query_frontend (
  Enum['present', 'absent']      $ensure                                   = 'present',
  String                         $user                                     = $thanos::user,
  String                         $group                                    = $thanos::group,
  Stdlib::Absolutepath           $bin_path                                 = $thanos::bin_path,
  Optional[Integer]              $max_open_files                           = undef,
  # Binary Parameters
  Thanos::Log_level              $log_level                                = 'info',
  Enum['logfmt', 'json']         $log_format                               = 'logfmt',
  Optional[Stdlib::Absolutepath] $tracing_config_file                      = $thanos::tracing_config_file,
  String                         $query_range_split_interval               = '24h',
  Integer                        $query_range_max_retries_per_request      = 5,
  Integer                        $query_range_max_query_length             = 0,
  Integer                        $query_range_max_query_parrallelism       = 14,
  String                         $query_range_response_cache_max_freshness = '1m',
  Boolean                        $query_range_partial_response             = false,
  Optional[Stdlib::Absolutepath] $query_range_response_cache_config_file   = undef,
  String                         $http_address                             = '0.0.0.0:10902',
  String                         $http_grace_period                        = '2m',
  Stdlib::HTTPUrl                $query_frontend_downstream_url            = 'http://localhost:9090',
  Boolean                        $query_frontend_compress_responses        = false,
  Integer                        $query_frontend_log_queries_longer_than   = 0,
  Optional[String]               $log_request_decision                     = undef,
  # Extra parametes
  Hash                           $extra_params                             = {},
) {
  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'query-frontend':
    ensure         => $_service_ensure,
    bin_path       => $bin_path,
    user           => $user,
    group          => $group,
    max_open_files => $max_open_files,
    params         => {
      'log.level'                                => $log_level,
      'log.format'                               => $log_format,
      'tracing.config-file'                      => $tracing_config_file,
      'query-range.split-interval'               => $query_range_split_interval,
      'query-range.max-retries-per-request'      => $query_range_max_retries_per_request,
      'query-range.max-query-length'             => $query_range_max_query_length,
      'query-range.max-query-parallelism'        => $query_range_max_query_parrallelism,
      'query-range.response-cache-max-freshness' => $query_range_response_cache_max_freshness,
      'query-range.partial-response'             => $query_range_partial_response,
      'query-range.response-cache-config-file'   => $query_range_response_cache_config_file,
      'http-address'                             => $http_address,
      'http-grace-period'                        => $http_grace_period,
      'query-frontend.downstream-url'            => $query_frontend_downstream_url,
      'query-frontend.compress-responses'        => $query_frontend_compress_responses,
      'query-frontend.log-queries-longer-than'   => $query_frontend_log_queries_longer_than,
      'log.request.decision'                     => $log_request_decision,
    },
    extra_params   => $extra_params,
  }
}
