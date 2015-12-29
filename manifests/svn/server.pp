

class replication::svn::server (
    $sync_username,
    $sync_password,
    $source_username,
    $source_password,
    $repo_location,
    $svn_hook_prerequisites = 'Class[subversion]',
    $logfile                = $replication::svn::params::logfile,
    $target_url             = $replication::svn::params::target_url,
    $present                = $replication::svn::params::present,
    $client_tunnels         = undef,
    ) inherits replication::svn::params {

    if($present == true){

        unless ( $client_tunnels == undef ) {
            include stunnel_config
            create_resources('stunnel_config::tun', $client_tunnels)
        }
        
        include subversion

        Subversion::Svnrepo<| |> -> File['svn_post_commit_hook_template']

        file {'svn_post_commit_hook_template' :
                ensure  => file,
                content => template('replication/svn_post_commit_hook.erb'),
                path    => "${repo_location}/hooks/post-commit",
                owner   => 'root',
                group   => 'root',
                mode    => '0755',
                require => $svn_hook_prerequisites,
        }
    }
}

