# /etc/puppet/modules/httpd_asf/manifests/low.pp

# httpd:asf low class
class httpd_asf::low (

$::apache::mod::event::listenbacklog = '511',
$::apache::mod::event::maxclients = '50',
$::apache::mod::event::maxconnectionsperchild = '2000',
$::apache::mod::event::maxrequestworkers = '20',
$::apache::mod::event::maxsparethreads = '10',
$::apache::mod::event::minsparethreads = '5',
$::apache::mod::event::serverlimit = '5',
$::apache::mod::event::startservers = '2',
$::apache::mod::event::threadlimit = '15',
$::apache::mod::event::threadsperchild = '5',

) {

}
