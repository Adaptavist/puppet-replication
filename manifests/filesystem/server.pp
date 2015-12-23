class replication::filesystem::server(
    $lsync_use_upstart     = $replication::filesystem::params::use_upstart,
    $lsync_inotify_watches = $replication::filesystem::params::inotify_watches,
    $lsync_create_files    = $replication::filesystem::params::create_files,
    $rsync_modules         = $replication::filesystem::params::rsync_modules,
    $server_tunnels        = $replication::filesystem::params::server_tunnels,
    $present               = $replication::filesystem::params::present,
    $create_daily_cron     = $replication::filesystem::params::create_daily_cron,
    $cron_user             = $replication::filesystem::params::cron_user,
    $cron_file             = $replication::filesystem::params::cron_file,
    $cron_rsync_path       = $replication::filesystem::params::cron_rsync_path,
    $cron_rsync_opts       = $replication::filesystem::params::cron_rsync_opts,
    $lsync_flush_config    = $replication::filesystem::params::lsync_flush_config,

    ) inherits replication::filesystem::params {
    
    if ($present == true){
        if ! defined(Class['lsyncd']) {
            #setup rsync server
            class { 'lsyncd' :
                use_upstart     => $lsync_use_upstart,
                inotify_watches => $lsync_inotify_watches,
                rsync_modules   => $rsync_modules,
                create_files    => $lsync_create_files,
                flush_config    => $lsync_flush_config,
            }
        }

        # if a daily cron is required create it
        if ($create_daily_cron == true) {
            file {'lsync_daily_sync_script':
                ensure  => file,
                content => template('replication/lsync_daily_sync.erb'),
                path    => "$cron_file",
                owner   => 'root',
                group   => 'root',
                mode    => '0755'
            }
        }

        unless ( $server_tunnels == undef ) {
            include stunnel_config
            create_resources('stunnel_config::tun', $server_tunnels)
        }
    }
}
