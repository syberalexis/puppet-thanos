# @summary This class manages configuration files
#
# This class install and manage configuration files like object store and tracing.
#
# @param manage_objstore_config
#  Whether to manage storage configuration file.
# @param objstore_config_file
#  Path to storage configuration file.
# @param objstore_config
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
# @example
#   include thanos::config
class thanos::config (
  Boolean                        $manage_objstore_config = $thanos::manage_objstore_config,
  Optional[Stdlib::Absolutepath] $objstore_config_file   = $thanos::objstore_config_file,
  Hash[String, Data]             $objstore_config        = $thanos::objstore_config,
  Boolean                        $manage_tracing_config  = $thanos::manage_tracing_config,
  Optional[Stdlib::Absolutepath] $tracing_config_file    = $thanos::tracing_config_file,
  Hash[String, Data]             $tracing_config         = $thanos::tracing_config,
) {
  assert_private()

  if $manage_objstore_config {
    thanos::config::objstore { $objstore_config_file:
      * => $objstore_config
    }
  }

  if $manage_tracing_config {
    thanos::config::tracing { $tracing_config_file:
      * => $tracing_config
    }
  }
}
