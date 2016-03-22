

class replication::database::server (
    $server_tunnels = $replication::database::params::server_tunnels,
    $present        = $replication::database::params::present,
    ) inherits replication::database::params {
    if str2bool($present){
        unless ( $server_tunnels == undef ) {
            include stunnel_config
            create_resources('stunnel_config::tun', $server_tunnels)
        }
    }
}