# = Class: replication:filesystem::client

class replication::filesystem::client(
    $use_xinetd     = $replication::filesystem::params::use_xinetd,
    $rsync_opts     = $replication::filesystem::params::rsync_opts,
    $address        = $replication::filesystem::params::address,
    $folders        = $replication::filesystem::params::folders,
    $client_tunnels = $replication::filesystem::params::client_tunnels,
    $present        = $replication::filesystem::params::present,
    $create_folders = $replication::filesystem::params::create_folders,
    ) inherits replication::filesystem::params {
    
    if ($present == true){
        if ! defined(Class['rsync_config']) {
            #setup rsync server
            class { 'rsync_config' :
                use_xinetd => $use_xinetd,
                rsync_opts => $rsync_opts,
                address    => $address,
                modules    => $folders,
            }
        }
        
        unless ( $client_tunnels == undef ) {
            include stunnel_config
            create_resources('stunnel_config::tun', $client_tunnels)
        }

        unless ($create_folders == undef){
            create_resources('file', $create_folders)
        }
    }
}

