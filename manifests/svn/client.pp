# = Class: client
#
class replication::svn::client(
    $server_url,
    $client_url,
    $client_hooks_path = undef,
    $server_user,
    $server_password,
    $local_user,
    $local_password,
    $client_tunnels    = $replication::svn::params::client_tunnels,
    $present           = $replication::svn::params::present,
    ) inherits replication::svn::params {

    if str2bool($present){
        include subversion

        unless ( $client_tunnels == undef ) {
            Stunnel_config::Tun<| |> -> File['svn_client_replication_template']
            include stunnel_config
            create_resources('stunnel_config::tun', $client_tunnels)
        }

        unless ( $client_hooks_path == undef ){
            file {'svn-pre-revprop-change':
                    ensure  => file,
                    content => template('replication/svn_pre-revprop-change.erb'),
                    path    => "${client_hooks_path}/pre-revprop-change",
                    owner   => 'root',
                    group   => 'root',
                    mode    => '0775',
                    require => Class['subversion'],
            }
        }

        Subversion::Svnrepo<| |> -> Exec['execute_db_dump_script']

        file {'svn_client_replication_template':
                ensure  => file,
                content => template('replication/svn_client_replication.sh.erb'),
                path    => '/var/opt/svn_client_replication.sh',
                owner   => 'root',
                group   => 'root',
                mode    => '0744',
                require => Class['subversion'],
        } ->
        exec {'execute_db_dump_script':
                command   => '/var/opt/svn_client_replication.sh',
                logoutput => on_failure,
        } ->
        exec {'remove_svn_client_replication_script':
                command   => 'rm -f /var/opt/svn_client_replication.sh',
                logoutput => on_failure,
                onlyif    => ['test -f /var/opt/svn_client_replication.sh'],
                path      => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
        }
    }
}
