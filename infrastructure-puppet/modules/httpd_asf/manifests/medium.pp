# /etc/puppet/modules/httpd_asf/manifests/medium.pp

# httpd:asf medium class
class httpd_asf::medium (

$::apache::mod::event::listenbacklog = '511',
$::apache::mod::event::maxclients = '100',
$::apache::mod::event::maxconnectionsperchild = '20000',
$::apache::mod::event::maxrequestworkers = '200',
$::apache::mod::event::maxsparethreads = '100',
$::apache::mod::event::minsparethreads = '50',
$::apache::mod::event::serverlimit = '20',
$::apache::mod::event::startservers = '6',
$::apache::mod::event::threadlimit = '125',
$::apache::mod::event::threadsperchild = '20',

) {

}
