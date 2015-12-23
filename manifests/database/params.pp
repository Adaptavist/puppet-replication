# = Class: replication::params
#
class replication::database::params {
    $present = true
    $from_server = '127.0.0.1'
    $from_port = '13306'
    $to_server = '127.0.0.1'
    $to_port = '3306'

    $semanage_package = $::osfamily ? {
        'RedHat' => 'policycoreutils-python',
        'Debian' => 'policycoreutils',
    }


    # Example stunnel configuration
    # $client_tunnels = {
    #   'mysql' => {
    #     'accept' => '127.0.0.1:13306',
    #     'connect' => "<SERVER_HOSTNAME>:13306",
    #     'certificate' => '/etc/stunnel/stunnel.pem',
    #     'ca_file' => '/etc/stunnel/stunnel.pem',
    #     'verify' => '2',
    #     'chroot' => '/var/lib/stunnel4/',
    #     'user' => 'stunnel4',
    #     'group' => 'stunnel4',
    #     'pid_file' => '/stunnel4-rsync.pid',
    #     'ssl_options' => 'NO_SSLv2',
    #     'client' => 'true',
    #     'retry' => 'true',
    #     'foreground' => 'false',
    #     }
    # }

    # $server_tunnels = {
    #   'mysql' => {
    #     'accept' => '13306',
    #     'connect' => '3306',
    #     'certificate' => '/etc/stunnel/stunnel.pem',
    #     'ca_file' => '/etc/stunnel/stunnel.pem',
    #     'verify' => '2',
    #     'chroot' => '/var/lib/stunnel4/',
    #     'user' => 'stunnel4',
    #     'group' => 'stunnel4',
    #     'pid_file' => '/stunnel4-rsync.pid',
    #     'ssl_options' => 'NO_SSLv2',
    #     'client' => false,
    #     'foreground' => false,
    #     }
    # }

}