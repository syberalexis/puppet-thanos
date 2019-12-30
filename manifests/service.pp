# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include thanos::service
class thanos::service {
  service { 'thanos':
    ensure => running,
    enable => true,
  }
}
