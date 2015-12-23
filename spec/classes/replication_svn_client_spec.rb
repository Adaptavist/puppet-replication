require 'spec_helper'
 
describe 'replication::svn::client', :type => 'class' do
    
  context "Should include replication svn" do
    let :params do
      { 
        :server_url => 'http://localhost:repo1',
        :client_url => 'http://localhost:repo',
        :server_user => 'user',
        :server_password => 'pass',
        :local_user => 'user1',
        :local_password => 'pass2' 
        }
    end
    it do
      should contain_class('subversion')
      should contain_file('svn_client_replication_template').with({
        'ensure'  => 'file',
        'path'    => "/var/opt/svn_client_replication.sh",
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0744',
        }).that_comes_before('Exec[execute_db_dump_script]')

        should contain_exec('execute_db_dump_script').with({
                'command'     => '/var/opt/svn_client_replication.sh',
                'logoutput'   => 'on_failure',
        }).that_comes_before('Exec[remove_svn_client_replication_script]')

        should contain_exec('remove_svn_client_replication_script').with({
                'command'     => 'rm -f /var/opt/svn_client_replication.sh',
                'logoutput'   => 'on_failure',
                'onlyif'      => ['test -f /var/opt/svn_client_replication.sh'],
        })
    end
  end
end
