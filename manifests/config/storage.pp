# @summary Manage Storage configuration file.
#
# Manage Storage configuration file.
#
# @param ensure
#  State ensured from configuration file.
# @param type
#  Type of Storage configurarion.
#    One of ['S3', 'GCS', 'AZURE', 'SWIFT', 'COS', 'ALIYUNOSS', 'FILESYSTEM']
# @param config
#  Configuration to typed storage.
# @param prefix 
#  Set the prefix for to be used on the storage
# @example
#   thanos::config::storage { '/etc/thanos/storage.yaml':
#     ensure => 'present',
#     type   => 'FILESYSTEM',
#     config => {
#       directory => '/data',
#     },
#   }
define thanos::config::storage (
  Enum['present', 'absent'] $ensure,
  Thanos::Storage_type      $type,
  Hash[String, Data]        $config,
  String                    $prefix = '', # lint:ignore:params_empty_string_assignment
) {
  $_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent'
  }

  $configs = {
    type   => $type,
    prefix => $prefix,
    config => $config,
  }

  file { $title:
    ensure  => $_ensure,
    content => $configs.to_yaml(),
  }
}
