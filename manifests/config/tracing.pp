# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   thanos::config::tracing { 'namevar': }
define thanos::config::tracing (
  Enum['present', 'absent']                                 $ensure,
  Enum['JAEGER', 'STACKDRIVER', 'ELASTIC_APM', 'LIGHTSTEP'] $type,
  Hash[String, Data]                                        $config,
) {
  $_ensure = $ensure ? {
    'present' => 'file',
    default   => 'absent'
  }

  file { $title:
    ensure  => $_ensure,
    content => template('thanos/config.erb'),
  }
}
