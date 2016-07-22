class replication::database::postgres_client (
    $from_server,
    $from_port,
    $replication_user,
    $replication_password,
    $replication_lock_file_path    = '/etc/puppet/files',
    $postgres_service_stop_command = 'false',
    $postgres_user_home            = '',
    ) {

    if ($postgres_user_home and $postgres_user_home != '') {
        $real_postgres_user_home = $postgres_user_home
    } else {
        $real_postgres_user_home = "${postgresql::server::datadir}/.."
    }

    if ($postgres_service_stop_command and $postgres_service_stop_command != 'false') {
        $real_postgres_service_stop_command = $postgres_service_stop_command
    } else {
        $real_postgres_service_stop_command = "service ${postgresql::server::service_name} stop"
    }

    exec {'stop_postgres_service':
        command   => $real_postgres_service_stop_command,
        logoutput => on_failure,
        unless    => ["test -f ${replication_lock_file_path}/initial_sync_done.lock"],
        require   => Class['postgresql::server::initdb'],
        before    => Exec['start_base_backup_for_user'],
    }

    file { "${real_postgres_user_home}/.pgpass":
        ensure  => file,
        content => "*:*:*:${replication_user}:${replication_password}",
        owner   => $postgresql::server::user,
        group   => $postgresql::server::group,
        mode    => '0600',
    } ->
    exec { 'start_base_backup_for_user':
        command   => "rm -rf ${postgresql::server::datadir}/*; sudo -u ${postgresql::server::user} \
        pg_basebackup -h ${from_server} -D ${postgresql::server::datadir} -U ${replication_user} -p ${from_port} -v -P -w",
        unless    => ["test -f ${replication_lock_file_path}/initial_sync_done.lock"],
        logoutput => on_failure
    } ->
    file {"${replication_lock_file_path}/initial_sync_done.lock":
        ensure => file,
        owner  => $postgresql::server::user,
        group  => $postgresql::server::group,
        mode   => '0644',
        before => Class['postgresql::server::config']
    }
    Exec['start_base_backup_for_user'] -> Postgresql::Server::Config_entry<||>
}

