# @summary This module manages Thanos
#
# Init class of Thanos module. It can installes Thanos binaries and manages components as single Service.
#
# @param version
#  Thanos release. See https://github.com/thanos-io/thanos/releases
# @param os
#  Operating system.
# @param manage_sidecar
#  Whether to create a service to run Sidecar.
# @param manage_query
#  Whether to create a service to run Query.
# @param manage_rule
#  Whether to create a service to run Rule.
# @param manage_store
#  Whether to create a service to run Store.
# @param manage_compact
#  Whether to create a service to run Compact.
# @param manage_downsample
#  Whether to create a service to run Downsample.
# @param install_method
#  Installation method: url or package (only url is supported currently).
# @param package_ensure
#  If package, then use this for package ensurel default 'latest'.
# @param package_name
#  Thanos package name - not available yet.
# @param base_url
#  Base URL for thanos.
# @param download_extension
#  Extension of Thanos binaries archive.
# @param download_url
#  Complete URL corresponding to the Thanos release, default to undef.
# @param base_dir
#  Base directory where Thanos is extracted.
# @param bin_dir
#  Directory where binaries are located.
# @param tsdb_path
#  Data directory of TSDB.
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
# @param extract_command
#  Custom command passed to the archive resource to extract the downloaded archive.
# @example
#   include thanos
class thanos (
  Pattern[/\d+\.\d+\.\d+/]       $version,
  String                         $os                 = downcase($facts['kernel']),
  Boolean                        $manage_sidecar     = false,
  Boolean                        $manage_query       = false,
  Boolean                        $manage_rule        = false,
  Boolean                        $manage_store       = false,
  Boolean                        $manage_compact     = false,
  Boolean                        $manage_downsample  = false,

  # Installation
  Enum['url', 'package', 'none'] $install_method     = 'url',
  Enum['present', 'absent']      $package_ensure     = 'present',
  String                         $package_name       = 'thanos',
  Stdlib::HTTPUrl                $base_url           = 'https://github.com/thanos-io/thanos/releases/download',
  String                         $download_extension = 'tar.gz',
  Optional[Stdlib::HTTPUrl]      $download_url       = undef,
  Stdlib::Absolutepath           $base_dir           = '/opt',
  Stdlib::Absolutepath           $bin_dir            = '/usr/local/bin',
  Stdlib::Absolutepath           $tsdb_path          = '/opt/prometheus/data',

  # User Management
  Boolean                        $manage_user        = true,
  Boolean                        $manage_group       = true,
  String                         $user               = 'thanos',
  String                         $group              = 'thanos',
  Stdlib::Absolutepath           $usershell          = '/bin/false',
  Array[String]                  $extra_groups       = [],
  Optional[String]               $extract_command    = undef,
) {
  $bin_path = "${bin_dir}/thanos"

  $notify_services = {
    'sidecar'    => $manage_sidecar,
    'query'      => $manage_query,
    'rule'       => $manage_rule,
    'store'      => $manage_store,
    'compact'    => $manage_compact,
    'downsample' => $manage_downsample,
  }.filter |String $key, Boolean $value| {
    $value
  }.map |String $key, Boolean $value| {
    Service["thanos-${key}"]
  }

  case $facts['os']['architecture'] {
    'x86_64', 'amd64': { $real_arch = 'amd64' }
    'aarch64':         { $real_arch = 'arm64' }
    default:           {
      fail("Unsupported kernel architecture: ${facts['os']['architecture']}")
    }
  }

  if $download_url {
    $real_download_url = $download_url
  } else {
    $real_download_url = "${base_url}/v${version}/thanos-${version}.${os}-${real_arch}.${download_extension}"
  }

  include thanos::install

  if $manage_sidecar {
    include thanos::sidecar
    Class['thanos::install'] -> Class['thanos::sidecar']
  }

  if $manage_query {
    include thanos::query
    Class['thanos::install'] -> Class['thanos::query']
  }

  if $manage_rule {
    include thanos::rule
    Class['thanos::install'] -> Class['thanos::rule']
  }

  if $manage_store {
    include thanos::store
    Class['thanos::install'] -> Class['thanos::store']
  }

  if $manage_compact {
    include thanos::compact
    Class['thanos::install'] -> Class['thanos::compact']
  }

  if $manage_downsample {
    include thanos::downsample
    Class['thanos::install'] -> Class['thanos::downsample']
  }
}
