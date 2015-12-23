class replication::database::client (
    $from_server      = $replication::database::params::from_server,
    $from_port        = $replication::database::params::from_port,
    $to_server        = $replication::database::params::to_server,
    $to_port          = $replication::database::params::to_port,
    $databases        = undef, #will fallback to all databases except the system ones
    $replication_user,
    $replication_password,
    $dump_user,
    $dump_password,
    $to_server_user,
    $to_server_password,
    $present          = $replication::database::params::present,
    $client_tunnels   = $replication::database::params::client_tunnels,
    $semanage_package = $replication::database::params::semanage_package,
    ) inherits replication::database::params {

    if($present == true){
        unless ( $client_tunnels == undef ) {
            include stunnel_config
            create_resources('stunnel_config::tun', $client_tunnels)
        }

        # set correct selinux context on the from_port so we can connect
        if str2bool($::selinux) {
            ensure_packages([$semanage_package])

            exec {'set_mysql_port_selinux_context':
                command     => "semanage port -a -t mysqld_port_t -p tcp ${from_port}",
                path        => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
                logoutput   => on_failure,
                before      => File['/var/opt/synchronize_database_with_slave.sh'],
                unless      => ["semanage port -l | grep 'mysqld_port_t.* ${from_port}[$,]'"],
                require     => Package[$semanage_package],
            }
        }

        file {'db_sync_template_script':
                ensure  => file,
                content => template('replication/sync_db.sh.erb'),
                path  => '/var/opt/synchronize_database_with_slave.sh',
                owner   => 'root',
                group   => 'root',
                mode    => '0744',
                require => 'Anchor[mysql::server::end]',
        } ->
        exec {'execute_db_dump_script':
                command     => '/var/opt/synchronize_database_with_slave.sh',
                logoutput   => on_failure,
                unless      => ['test -f /var/opt/initial_database_synchronization_done.lock'],
        } ->
        exec {'remove_synchronize_database_with_slave_script':
                command     => 'rm -f /var/opt/synchronize_database_with_slave.sh',
                logoutput   => on_failure,
                onlyif      => ['test -f /var/opt/synchronize_database_with_slave.sh'],
        }
    }
}
