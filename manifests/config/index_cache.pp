# @summary Manage Index cache configuration file.
#
# Manage Index cache configuration file.
#
# @param ensure
#  State ensured from configuration file.
# @param type
#  Type of Index cache.
#    One of ['IN-MEMORY', 'MEMCACHED']
# @param config
#  Configuration to typed index cache.
# @example
#   thanos::config::index_cache { '/etc/thanos/index_cache.yaml':
#     ensure => 'present',
#     type   => 'IN-MEMORY',
#     config => {
#       max_size      => 0,
#       max_item_size => 0,
#     },
#   }
define thanos::config::index_cache (
  Enum['present', 'absent'] $ensure,
  Thanos::Index_cache_type  $type,
  Hash[String, Data]        $config,
) {
  $_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent'
  }

  $configs = {
    type   => $type,
    config => $config,
  }

  file { $title:
    ensure  => $_ensure,
    content => $configs.to_yaml(),
  }
}
