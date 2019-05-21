class nfs::server::redhat(
  $nfs_v4 = false,
  $nfs_v4_idmap_domain = undef
) {

  if !defined(Class['nfs::client::redhat']) {
    class{ 'nfs::client::redhat':
      nfs_v4              => $nfs_v4,
      nfs_v4_idmap_domain => $nfs_v4_idmap_domain,
    }
  }

  include nfs::server::redhat::install, nfs::server::redhat::service


}
