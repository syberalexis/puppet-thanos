# @summary This class manages configuration files
#
# This class install and manage configuration files like object store and tracing.
#
# @param manage_storage_config
#  Whether to manage storage configuration file.
# @param storage_config_file
#  Path to storage configuration file.
# @param storage_config
#  Storage configuration.
#     type: one of ['S3', 'GCS', 'AZURE', 'SWIFT', 'COS', 'ALIYUNOSS', 'FILESYSTEM']
#     config: storage typed configuration in Hash[String, Data]
# @param manage_tracing_config
#  Whether to manage tracing configuration file
# @param tracing_config_file
#  Path to tracing configuration file.
# @param tracing_config
#  Tracing configuration.
#     type: one of ['JAEGER', 'STACKDRIVER', 'ELASTIC_APM', 'LIGHTSTEP']
#     config: tracing typed configuration in Hash[String, Data]
# @param manage_index_cache_config
#  Whether to manage index cache configuration file
# @param index_cache_config_file
#  Path to index cache configuration file.
# @param index_cache_config
#  Index cache configuration.
#     type: one of ['IN-MEMORY', 'MEMCACHED']
#     config: index cache typed configuration in Hash[String, Data]
# @example
#   include thanos::config
class thanos::config (
  Boolean                        $manage_storage_config     = $thanos::manage_storage_config,
  Optional[Stdlib::Absolutepath] $storage_config_file       = $thanos::storage_config_file,
  Hash[String, Data]             $storage_config            = $thanos::storage_config,
  Boolean                        $manage_tracing_config     = $thanos::manage_tracing_config,
  Optional[Stdlib::Absolutepath] $tracing_config_file       = $thanos::tracing_config_file,
  Hash[String, Data]             $tracing_config            = $thanos::tracing_config,
  Boolean                        $manage_index_cache_config = $thanos::manage_index_cache_config,
  Optional[Stdlib::Absolutepath] $index_cache_config_file   = $thanos::index_cache_config_file,
  Hash[String, Data]             $index_cache_config        = $thanos::index_cache_config,
) {
  assert_private()

  if $manage_storage_config {
    thanos::config::storage { $storage_config_file:
      ensure => $storage_config['ensure'],
      type   => $storage_config['type'],
      config => $storage_config['config'],
      user   => $thanos::user,
      group  => $thanos::group,
      prefix => $storage_config['prefix'],
    }
  }

  if $manage_tracing_config {
    thanos::config::tracing { $tracing_config_file:
      ensure => $tracing_config['ensure'],
      type   => $tracing_config['type'],
      config => $tracing_config['config'],
      user   => $thanos::user,
      group  => $thanos::group,
    }
  }

  if $manage_index_cache_config {
    thanos::config::index_cache { $index_cache_config_file:
      * => $index_cache_config,
    }
  }
}
