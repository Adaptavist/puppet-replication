# = Class: replication::params
#
class replication::svn::params {
    $logfile            = '/var/log/svn.log'
    $target_url         = 'http://localhost:18000/svn'
    $present            = true
}