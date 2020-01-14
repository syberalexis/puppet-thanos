# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::service
define thanos::resources::service (
  Variant[Stdlib::Ensure::Service, Enum['absent']] $ensure,
  Stdlib::Absolutepath                             $bin_path,
  Hash                                             $params,
) {
  $_service_name   = "thanos-${title}"
  $_service_ensure = $ensure ? {
    running => running,
    default => stopped,
  }
  $_file_ensure    = $ensure ? {
    running => file,
    stopped => file,
    default => absent,
  }

  $parameters = $params.filter |String $key, Data $value| {
    if $value {
      $value
    }
  }.map |String $key, Data $value| {
    if $value.is_a(Array) {
      $value.prefix("--${key}=").join(" \\\n")
    } elsif $value.is_a(Boolean) {
      "--${key}"
    } else {
      "--${key}=${value}"
    }
  }.join(" \\\n")

  file { "/lib/systemd/system/${_service_name}.service":
    ensure  => $_file_ensure,
    content => template('thanos/service.erb'),
  }
  service { $_service_name:
    ensure => $_service_ensure,
    enable => true,
  }

  File["/lib/systemd/system/${_service_name}.service"] -> Service[$_service_name]
}
