# = Class: warm_replication
#
class replication::warm_replication::server(
    $instance_name,
    $ensure = 'present',
    $instance_db_name = undef,
    $instance_db_host = '127.0.0.1',
    $instance_db_port = undef,
    $instance_db_user = undef,
    $instance_db_pass = undef,
    $custom_reload_database_command = undef,
    $custom_check_status_command = undef,
    $custom_start_command = undef,
    $custom_stop_command = undef,
    $custom_sync_filesystem_command = undef,
    $sync_from = '/opt/',
    $sync_to = 'localhost::opt/',
    $sync_exclude = undef,
    $custom_tmp_file_to_remove = undef,
    $check_retry = 5,
    $run_as = 'root',
    $month    = '*',
    $monthday = '*',
    $hour     = '12',
    $minute   = '0',
    $server_tunnels = {},
    ){

    if ($custom_check_status_command == undef) {
        $real_check_status_command = "ps -ef | egrep '(${instance_name}.*Xms)' | grep -v egrep | wc -l"
    } else {
        $real_check_status_command = $custom_check_status_command
    }

    if ($custom_tmp_file_to_remove == undef) {
        $real_tmp_file_to_remove = "/opt/${instance_name}/install/var/tmp/*.tmp"
    } else {
        $real_tmp_file_to_remove = $custom_tmp_file_to_remove
    }

    if ($custom_stop_command == undef) {
        $real_stop_command = "/sbin/stop ${instance_name} > /dev/null"
    } else {
        $real_stop_command = $custom_stop_command
    }

    if ($custom_start_command == undef) {
        $real_start_command = "/sbin/start ${instance_name} > /dev/null"
    } else {
        $real_start_command = $custom_start_command
    }

    if ($custom_reload_database_command == undef){
        $real_reload_database_command = "/usr/bin/mysqldump ${instance_db_name} | /usr/bin/mysql --host ${instance_db_host} \
        --port ${instance_db_port} -u ${instance_db_user}  -p${instance_db_pass} ${instance_db_name}"
    } else {
        $real_reload_database_command = $custom_reload_database_command
    }

    if ($custom_sync_filesystem_command == undef){
        if $sync_exclude == undef {
            $real_sync_filesystem_command = "/usr/bin/rsync -ravH --delete ${sync_from} ${sync_to} > /dev/null"
        } else {
            $real_sync_filesystem_command = "/usr/bin/rsync -ravH --delete ${sync_from} ${sync_to} --exclude ${sync_exclude} > /dev/null"
        }
    } else {
        $real_sync_filesystem_command = $custom_sync_filesystem_command
    }

    $cron_command = '/var/opt/warm_replication.sh'

    unless ( $server_tunnels == undef ) {
            include stunnel_config
            create_resources('stunnel_config::tun', $server_tunnels)
    }

    file {'warm_copy_#{instance_name}_template_script':
        ensure  => file,
        content => template('replication/warm_replication.sh.erb'),
        path    => '/var/opt/warm_replication.sh',
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
    } -> cron { "create_warm_copy_${instance_name}_cronjob":
        ensure   => $ensure,
        command  => $cron_command,
        user     => 'root',
        month    => $month,
        monthday => $monthday,
        hour     => $hour,
        minute   => $minute,
    }

}
