require 'spec_helper'

describe 'replication::database::server', :type => 'class' do
  let :facts do
    {
      'osfamily' => 'RedHat'
    }
  end
  context "Should include replication database" do
    let :params do
      { :server_tunnels => {
        'mysql' => {
          'accept' => '13306',
          'connect' => '3306',
          'certificate' => '/etc/stunnel/stunnel.pem',
          'ca_file' => '/etc/stunnel/stunnel.pem',
          'verify' => '2',
          'chroot' => '/var/lib/stunnel4/',
          'user' => 'stunnel4',
          'group' => 'stunnel4',
          'pid_file' => '/stunnel4-rsync.pid',
          'ssl_options' => 'NO_SSLv2',
          'client' => false,
          'foreground' => false,
          }
        }
        }
    end
    it do
      should contain_stunnel_config__tun('mysql').with({
        'accept' => '13306',
          'connect' => '3306',
          'certificate' => '/etc/stunnel/stunnel.pem',
          'ca_file' => '/etc/stunnel/stunnel.pem',
          'verify' => '2',
          'chroot' => '/var/lib/stunnel4/',
          'user' => 'stunnel4',
          'group' => 'stunnel4',
          'pid_file' => '/stunnel4-rsync.pid',
          'ssl_options' => 'NO_SSLv2',
          'client' => false,
          'foreground' => false,
        })
    end
  end
end
