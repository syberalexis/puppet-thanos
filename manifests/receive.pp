# @summary This class manages receiver service
#
# This class install Receiver as service that implements the Prometheus Remote Write API.
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
# @param remote_write_address
#  Address to listen on for remote write requests.
# @param remote_write_server_tls_cert
#  TLS Certificate for HTTP server, leave blank to disable TLS.
# @param remote_write_server_tls_key
#  TLS Key for the HTTP server, leave blank to disable TLS.
# @param remote_write_server_tls_client_ca
#  TLS CA to verify clients against. If no client CA is specified, there is no client verification on server side. (tls.NoClientCert)
# @param remote_write_client_tls_cert
#  TLS Certificates to use to identify this client to the server.
# @param remote_write_client_tls_key
#  TLS Key for the client's certificate.
# @param remote_write_client_tls_ca
#  TLS CA Certificates to use to verify servers.
# @param remote_write_client_server_name
#  Server name to verify the hostname on the returned gRPC certificates. See https://tools.ietf.org/html/rfc4366#section-3.1
# @param tsdb_path
#  Data directory of TSDB.
# @param objstore_config_file
#  Path to YAML file that contains object store configuration. See format details: https://thanos.io/storage.md/#configuration
# @param tsdb_retention
#  How long to retain raw samples on local storage. 0d - disables this retention.
# @param receive_hashrings_file
#  Path to file that contains the hashring configuration.
# @param receive_hashrings_file_refresh_interval
#  Refresh interval to re-read the hashring configuration file. (used as a fallback)
# @param receive_local_endpoint
#  Endpoint of local receive node. Used to identify the local node in the hashring configuration.
# @param receive_tenant_header
#  HTTP header to determine tenant for write requests.
# @param receive_default_tenant_id
#  HDefault tenant ID to use when none is provided via a header.
# @param receive_tenant_label_name
#  Label name through which the tenant will be announced.
# @param receive_replica_header
#  HTTP header specifying the replica number of a write request.
# @param receive_replication_factor
#  How many times to replicate incoming write requests.
# @param tsdb_wal_compression
#  Compress the tsdb WAL.
# @param tsdb_no_lockfile
#  Do not create lockfile in TSDB data directory.
#    In any case, the lockfiles will be deleted on next startup.
# @param labels
#  External labels to announce.
#    This flag will be removed in the future when handling multiple tsdb instances is added.
# @param extra_params
#  Parameters passed to the binary, ressently released in latest version of Thanos.
# @example
#   include thanos::downsample
class thanos::receive (
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
  String                         $grpc_address                            = '0.0.0.0:10901',
  String                         $grpc_grace_period                       = '2m',
  Optional[Stdlib::Absolutepath] $grpc_server_tls_cert                    = undef,
  Optional[Stdlib::Absolutepath] $grpc_server_tls_key                     = undef,
  Optional[Stdlib::Absolutepath] $grpc_server_tls_client_ca               = undef,
  String                         $remote_write_address                    = '0.0.0.0:19291',
  Optional[Stdlib::Absolutepath] $remote_write_server_tls_cert            = undef,
  Optional[Stdlib::Absolutepath] $remote_write_server_tls_key             = undef,
  Optional[Stdlib::Absolutepath] $remote_write_server_tls_client_ca       = undef,
  Optional[Stdlib::Absolutepath] $remote_write_client_tls_cert            = undef,
  Optional[Stdlib::Absolutepath] $remote_write_client_tls_key             = undef,
  Optional[Stdlib::Absolutepath] $remote_write_client_tls_ca              = undef,
  Optional[String]               $remote_write_client_server_name         = undef,
  Optional[Stdlib::Absolutepath] $tsdb_path                               = undef,
  Optional[Stdlib::Absolutepath] $objstore_config_file                    = $thanos::storage_config_file,
  String                         $tsdb_retention                          = '15d',
  Optional[Stdlib::Absolutepath] $receive_hashrings_file                  = undef,
  String                         $receive_hashrings_file_refresh_interval = '5m',
  Optional[String]               $receive_local_endpoint                  = undef,
  String                         $receive_tenant_header                   = 'THANOS-TENANT',
  String                         $receive_default_tenant_id               = 'default-tenant',
  String                         $receive_tenant_label_name               = 'tenant_id',
  String                         $receive_replica_header                  = 'THANOS-REPLICA',
  Integer                        $receive_replication_factor              = 1,
  Boolean                        $tsdb_wal_compression                    = false,
  Boolean                        $tsdb_no_lockfile                        = false,
  Array[String]                  $labels                                  = [],
  # Extra parametes
  Hash                           $extra_params                            = {},
) {
  $_service_ensure = $ensure ? {
    'present' => 'running',
    default   => 'stopped'
  }

  thanos::resources::service { 'receive':
    ensure       => $_service_ensure,
    user         => $user,
    group        => $group,
    bin_path     => $bin_path,
    params       => {
      'log.level'                               => $log_level,
      'log.format'                              => $log_format,
      'tracing.config-file'                     => $tracing_config_file,
      'http-address'                            => $http_address,
      'http-grace-period'                       => $http_grace_period,
      'grpc-address'                            => $grpc_address,
      'grpc-grace-period'                       => $grpc_grace_period,
      'grpc-server-tls-cert'                    => $grpc_server_tls_cert,
      'grpc-server-tls-key'                     => $grpc_server_tls_key,
      'grpc-server-tls-client-ca'               => $grpc_server_tls_client_ca,
      'remote-write.address'                    => $remote_write_address,
      'remote-write.server-tls-cert'            => $remote_write_server_tls_cert,
      'remote-write.server-tls-key'             => $remote_write_server_tls_key,
      'remote-write.server-tls-client-ca'       => $remote_write_server_tls_client_ca,
      'remote-write.client-tls-cert'            => $remote_write_client_tls_cert,
      'remote-write.client-tls-key'             => $remote_write_client_tls_key,
      'remote-write.client-tls-ca'              => $remote_write_client_tls_ca,
      'remote-write.client-server-name'         => $remote_write_client_server_name,
      'tsdb.path'                               => $tsdb_path,
      'objstore.config-file'                    => $objstore_config_file,
      'tsdb.retention'                          => $tsdb_retention,
      'receive.hashrings-file'                  => $receive_hashrings_file,
      'receive.hashrings-file-refresh-interval' => $receive_hashrings_file_refresh_interval,
      'receive.local-endpoint'                  => $receive_local_endpoint,
      'receive.tenant-header'                   => $receive_tenant_header,
      'receive.default-tenant-id'               => $receive_default_tenant_id,
      'receive.tenant-label-name'               => $receive_tenant_label_name,
      'receive.replica-header'                  => $receive_replica_header,
      'receive.replication-factor'              => $receive_replication_factor,
      'tsdb.wal-compression'                    => $tsdb_wal_compression,
      'tsdb.no-lockfile'                        => $tsdb_no_lockfile,
      'label'                                   => $labels,
    },
    extra_params => $extra_params,
  }
}
