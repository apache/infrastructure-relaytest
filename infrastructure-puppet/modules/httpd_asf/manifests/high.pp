# /etc/puppet/modules/httpd_asf/manifests/high.pp

# httpd:asf high class
class httpd_asf::high (

  $::apache::mod::event::listenbacklog = '511',
  $::apache::mod::event::maxclients = '200',
  $::apache::mod::event::maxconnectionsperchild = '200000',
  $::apache::mod::event::maxrequestworkers = '500',
  $::apache::mod::event::maxsparethreads = '250',
  $::apache::mod::event::minsparethreads = '150',
  $::apache::mod::event::serverlimit = '40',
  $::apache::mod::event::startservers = '20',
  $::apache::mod::event::threadlimit = '500',
  $::apache::mod::event::threadsperchild = '50',

) {

}
