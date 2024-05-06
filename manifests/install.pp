# @summary This class install Thanos requirements and binaries.
#
# @param version
#  Thanos release. See https://github.com/thanos-io/thanos/releases
# @param package_name
#  Thanos package name - not available yet.
# @param os
#  Operating system.
# @param real_arch
#  Architecture (amd64 or arm64).
# @param package_ensure
#  If package, then use this for package ensurel default 'latest'.
# @param install_method
#  Installation method: url or package (only url is supported currently).
# @param download_extension
#  Extension of Thanos binaries archive.
# @param download_url
#  Complete URL corresponding to the Prometheus release, default to undef.
# @param extract_command
#  Custom command passed to the archive resource to extract the downloaded archive.
# @param base_dir
#  Base directory where Thanos is extracted.
# @param bin_dir
#  Directory where binaries are located.
# @param config_dir
#  Directory where configuration are located.
# @param purge_config_dir
#  Purge configuration directory.
# @param notify_services
#  Services to notify when binaries changed.
# @param manage_user
#  Whether to create user for thanos or rely on external code for that.
# @param manage_group
#  Whether to create user for thanos or rely on external code for that.
# @param user
#  User running thanos.
# @param group
#  Group under which thanos is running.
# @param usershell
#  if requested, we create a user for thanos. The default shell is false. It can be overwritten to any valid path.
# @param extra_groups
#  Add other groups to the managed user.
# @example
#   include thanos::install
class thanos::install (
  Pattern[/\d+\.\d+\.\d+/]            $version            = $thanos::version,
  String                              $package_name       = $thanos::package_name,
  String                              $os                 = $thanos::os,
  String                              $real_arch          = $thanos::real_arch,

  # Installation
  Enum['present', 'absent', 'latest'] $package_ensure     = $thanos::package_ensure,
  Enum['url', 'package', 'none']      $install_method     = $thanos::install_method,
  String                              $download_extension = $thanos::download_extension,
  Stdlib::HTTPUrl                     $download_url       = $thanos::real_download_url,
  Optional[String]                    $extract_command    = $thanos::extract_command,
  Stdlib::Absolutepath                $base_dir           = $thanos::base_dir,
  Stdlib::Absolutepath                $bin_dir            = $thanos::bin_dir,
  Stdlib::Absolutepath                $config_dir         = $thanos::config_dir,
  Boolean                             $purge_config_dir   = $thanos::purge_config_dir,
  Array[Type[Resource]]               $notify_services    = $thanos::notify_services,

  # User Management
  Boolean                             $manage_user        = $thanos::manage_user,
  Boolean                             $manage_group       = $thanos::manage_group,
  String                              $user               = $thanos::user,
  String                              $group              = $thanos::group,
  Stdlib::Absolutepath                $usershell          = $thanos::usershell,
  Array[String]                       $extra_groups       = $thanos::extra_groups,
) {
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
    ensure_resource('user', [$user], {
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
    ensure_resource('group', [$group], {
        ensure => 'present',
        system => true,
    })
  }

  file { $config_dir:
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    mode    => '0750',
    purge   => $purge_config_dir,
    recurse => $purge_config_dir,
  }
}
