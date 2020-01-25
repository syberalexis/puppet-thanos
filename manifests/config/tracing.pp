# @summary Manage Tracing configuration file.
#
# Manage Tracing configuration file
#
# @param ensure
#  State ensured from configuration file.
# @param type
#  Type of Tracing configurarion.
#    One of ['JAEGER', 'STACKDRIVER', 'ELASTIC_APM', 'LIGHTSTEP']
# @param config
#  Configuration to typed tracing.
# @example
#   thanos::config::tracing { '/etc/thanos/tracing.yaml':
#     ensure => 'present',
#     type   => 'JAEGER',
#     config => {...},
#   }
define thanos::config::tracing (
  Enum['present', 'absent']                                 $ensure,
  Enum['JAEGER', 'STACKDRIVER', 'ELASTIC_APM', 'LIGHTSTEP'] $type,
  Hash[String, Data]                                        $config,
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
