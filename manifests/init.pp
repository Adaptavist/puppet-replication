# = Class: replication
#

class replication(
        $present              = 'true',
        $database_replication = 'false',
        $filesystem_repolication = 'false',
        $svn_replication = 'false',
        $warm_replication = 'false',
        $stunnel_tunnels   = undef,
    ){

    if( str2bool($present) ){
        if ( str2bool($database_replication) ) {
            include replication::database::server
        }
        if ( str2bool($filesystem_repolication)) {
            include replication::filesystem::server
        }
        if (str2bool($svn_replication)) {
            include replication::svn::server
        }
        if (str2bool($warm_replication)) {
            include replication::warm_replication::server
        }
    
        unless ( $stunnel_tunnels == undef ) {
            include stunnel_config
            create_resources('stunnel_config::tun', $stunnel_tunnels)
        }
    }
}
