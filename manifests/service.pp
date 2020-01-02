# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::service
define thanos::service (
  Variant[Stdlib::Ensure::Service, Enum['absent']] $ensure,
  Stdlib::Absolutepath                             $bin_path,
  Hash                                             $params,
) {
  $_file_ensure = $ensure ? {
    running => file,
    stopped => file,
    default => absent,
  }

  file { "/lib/systemd/system/${title}.service":
    ensure  => $_file_ensure,
    content => template('thanos/service.erb'),
  }

  $_service_ensure = $ensure ? {
    running => running,
    default => stopped,
  }

  service { $title:
    ensure => $_service_ensure,
    enable => true,
  }

  File["/lib/systemd/system/${title}.service"] -> Service[$title]
}
