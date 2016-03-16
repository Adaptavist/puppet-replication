# = Class: replication::filesystem::params
# Author: Name Surname <name.surname@mail.com>
class replication::filesystem::params {

    $present = true
    # server setup
    # setup lsyncd
    $lsync_flush_config = true
    $inotify_watches = 40000
    $use_upstart = true
    $rsync_modules = {
      'opt' => {
        'type' => 'rsync',
        'source' => '/opt/',
        'target' => 'localhost::opt/',
        'init_sync' => false,
        'rsync_verbose' => true,
        'rsync_archive' => true,
        'rsync_hard_links' => true,
        'exclude_from' => '/etc/lsyncd/rsync.exclusions',
        }
    }
    $create_daily_cron = true
    $cron_user = 'root'
    $cron_file = '/etc/cron.daily/lsync_daily_sync'
    $cron_rsync_path = '/usr/bin/rsync'
    $cron_rsync_opts = '-ravH --delete'
    $create_monitor_cron = true
    $monitor_cron_schedule = '*/10 * * * *'
    $monitor_cron_user = 'root'
    $monitor_cron_cronfile = '/etc/cron.d/fs_replication_monitor'
    $monitor_cron_file = 'replication.lock'

    # client setup
    #setup rsync
    $use_xinetd = true
    $rsync_opts = '--address=127.0.0.1'
    $address = '127.0.0.1'

    $folders = {
      'opt' => {
        'path' => '/opt',
        'comment' => 'Opt DR sync',
        'read_only' => 'no',
        'list' => 'yes',
        'uid' => 'root',
        'gid' => 'root',
        }
    }

    # Example stunnel configuration
    #
    # $server_tunnels = {
    #   'rsync' => {
    #         'accept' => 'localhost:873',
    #         'connect' => '<CLIENT-HOSTNAME>:8873',
    #         'certificate' => '/etc/stunnel/stunnel.pem',
    #         'ca_file' => '/etc/stunnel/stunnel.pem',
    #         'verify' => '2',
    #         'chroot' => '/var/lib/stunnel4/',
    #         'user' => 'stunnel4',
    #         'group' => 'stunnel4',
    #         'pid_file' => '/stunnel4-rsync.pid',
    #         'ssl_options' => 'NO_SSLv2',
    #         'client' => true,
    #         'foreground' => false,
    #         'debug_level' => 7,
    #         'retry' => true,
    #     }
    # }
    # $client_tunnels = {
    #   'rsync' => {
    #     'accept' => '8873',
    #     'connect' => '873',
    #     'certificate' => '/etc/stunnel/stunnel.pem',
    #     'ca_file' => '/etc/stunnel/stunnel.pem',
    #     'verify' => '2',
    #     'chroot' => '/var/lib/stunnel4/',
    #     'user' => 'stunnel4',
    #     'group' => 'stunnel4',
    #     'pid_file' => '/stunnel4-rsync.pid',
    #     'ssl_options' => 'NO_SSLv2',
    #     'client' => 'false',
    #     'foreground' => 'false',
    #     }
    # }
}
