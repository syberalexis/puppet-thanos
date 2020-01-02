# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::install
class thanos::install (
  Pattern[/\d\.\d\.\d/]           $version            = $thanos::version,
  String                          $package_name       = $thanos::package_name,
  String                          $os                 = $thanos::os,
  String                          $real_arch          = $thanos::real_arch,

  # Installation
  String                          $package_ensure     = $thanos::package_ensure,
  Enum['url', 'package', 'none']  $install_method     = $thanos::install_method,
  String                          $download_extension = $thanos::download_extension,
  Stdlib::HTTPUrl                 $download_url       = $thanos::real_download_url,
  Optional[String]                $extract_command    = $thanos::extract_command,
  Stdlib::Absolutepath            $base_dir           = $thanos::base_dir,
  Stdlib::Absolutepath            $bin_dir            = $thanos::bin_dir,
  Stdlib::Absolutepath            $tsdb_path          = $thanos::tsdb_path,
  Stdlib::Absolutepath            $config_dir         = $thanos::config_dir,
  Boolean                         $purge_config_dir   = $thanos::purge_config_dir,
  Array[Type[Resource]]           $notify_services    = $thanos::notify_services,

  # User Management
  Boolean                         $manage_user        = $thanos::manage_user,
  Boolean                         $manage_group       = $thanos::manage_group,
  String                          $user               = $thanos::user,
  String                          $group              = $thanos::group,
  Stdlib::Absolutepath            $usershell          = $thanos::usershell,
  Array[String]                   $extra_groups       = $thanos::extra_groups,
) {
  assert_private()

  if $tsdb_path {
    file { $tsdb_path:
      ensure => 'directory',
      owner  => $user,
      group  => $group,
      mode   => '0755',
    }
  }
  case $install_method {
    'url': {
      archive { "/tmp/thanos-${version}.${download_extension}":
        ensure          => present,
        extract         => true,
        extract_path    => $base_dir,
        source          => $download_url,
        checksum_verify => false,
        creates         => "${base_dir}/thanos-${version}.${os}-${real_arch}/thanos",
        cleanup         => true,
        extract_command => $extract_command,
      }
      -> file {
        "${base_dir}/thanos-${version}.${os}-${real_arch}/thanos":
          owner => 'root',
          group => 0, # 0 instead of root because OS X uses "wheel".
          mode  => '0555';
        "${bin_dir}/thanos":
          ensure => link,
          notify => $notify_services,
          target => "${base_dir}/thanos-${version}.${os}-${real_arch}/thanos";
      }
    }
    'package': {
      package { $package_name:
        ensure => $package_ensure,
        notify => $notify_services,
      }
      if $manage_user {
        User[$user] -> Package[$package_name]
      }
    }
    'none': {}
    default: {
      fail("The provided install method ${install_method} is invalid")
    }
  }
  if $manage_user {
    ensure_resource('user', [ $user ], {
      ensure => 'present',
      system => true,
      groups => concat([$group], $extra_groups),
      shell  => $usershell,
    })

    if $manage_group {
      Group[$group] -> User[$user]
    }
  }
  if $manage_group {
    ensure_resource('group', [ $group ],{
      ensure => 'present',
      system => true,
    })
  }
  file { $config_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => $group,
    purge   => $purge_config_dir,
    recurse => $purge_config_dir,
  }
}
