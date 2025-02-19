# @summary This defined type create component's service.
#
# @param ensure
#  State ensured from component service.
# @param bin_path
#  Path where binary is located.
# @param user
#  User running thanos.
# @param group
#  Group under which thanos is running.
# @param max_open_files
#  Define the maximum open files the service is allowed to use
# @param params
#  Parameters passed to the binary.
# @param extra_params
#  Parameters passed to the binary, ressently released in latest version of Thanos.
#
# @example
#   thanos::resources::service { 'component_name':
#     ensure => 'running',
#     bin_path => '/usr/local/bin/thanos',
#   }
#
define thanos::resources::service (
  Variant[Stdlib::Ensure::Service, Enum['absent']] $ensure,
  Stdlib::Absolutepath                             $bin_path,
  String                                           $user,
  String                                           $group,
  Optional[Integer]                                $max_open_files = undef,
  Hash                                             $params         = {},
  Hash                                             $extra_params   = {},
  Array                                            $env_vars       = [],
) {
  $_service_name   = "thanos-${title}"
  $_service_ensure = $ensure ? {
    'running' => running,
    default   => stopped,
  }
  $_service_enabled = $ensure ? {
    'running' => true,
    default   => false,
  }
  $_file_ensure    = $ensure ? {
    'running' => file,
    'stopped' => file,
    default   => absent,
  }

  $parameters = stdlib::merge($params, $extra_params).filter |String $key, Data $value| {
    !!$value
  }.map |String $key, Data $value| {
    if $value.is_a(Array) {
      $value.prefix("  --${key}=").join(" \\\n")
    } elsif $value.is_a(Boolean) {
      "  --${key}"
    } else {
      "  --${key}=${value}"
    }
  }.filter |String $value| {
    !empty($value)
  }.join(" \\\n")

  file { "/lib/systemd/system/${_service_name}.service":
    ensure  => $_file_ensure,
    content => template('thanos/service.erb'),
    notify  => Exec["systemd reload for ${_service_name}"],
  }
  exec { "systemd reload for ${_service_name}":
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
    notify      => Service[$_service_name],
  }
  service { $_service_name:
    ensure => $_service_ensure,
    enable => $_service_enabled,
  }
}
