# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   thanos::config::objstore { 'namevar': }
define thanos::config::objstore (
  Enum['present', 'absent']                                             $ensure,
  Enum['S3', 'GCS', 'AZURE', 'SWIFT', 'COS', 'ALIYUNOSS', 'FILESYSTEM'] $type,
  Hash[String, Data]                                                    $config,
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
