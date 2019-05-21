# Debian specifix stuff
class nfs::server::debian(
  $nfs_v4 = false,
  $nfs_v4_idmap_domain = undef
) {

  if !defined(Class['nfs::client::debian']) {
    class{ 'nfs::client::debian':
      nfs_v4              => $nfs_v4,
      nfs_v4_idmap_domain => $nfs_v4_idmap_domain,
    }
  }

  include nfs::server::debian::install, nfs::server::debian::service
}
