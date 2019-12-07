# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos
class thanos (
  String  $arch,
  Optional[Stdlib::HTTPUrl] $download_url,
  Boolean $manage_sidecar = true,
) {
  case $arch {
    'x86_64', 'amd64': { $real_arch = 'amd64' }
    'aarch64':         { $real_arch = 'arm64' }
    default:           {
      fail("Unsupported kernel architecture: ${arch}")
    }
  }

  if $manage_sidecar {
    include thanos::sidecar
  }
}
