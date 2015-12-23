require 'spec_helper'

describe 'replication::database::client', :type => 'class' do
  let :facts do
    {
      'osfamily' => 'RedHat'
    }
  end

  context "Should include replication svn" do
    let :params do
      {
        :replication_user => 'user',
        :replication_password => 'pass' ,
        :dump_user => 'user1',
        :dump_password => 'pass1' ,
        :to_server_user => 'user2',
        :to_server_password => 'pass2' ,
        }
    end
    it do
      should contain_file('db_sync_template_script').with({
        'ensure'  => 'file',
        'path'    => "/var/opt/synchronize_database_with_slave.sh",
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0744',
        }).that_comes_before('Exec[execute_db_dump_script]')

        should contain_exec('execute_db_dump_script').with({
                'command'     => '/var/opt/synchronize_database_with_slave.sh',
                'logoutput'   => 'on_failure',
        }).that_comes_before('Exec[remove_synchronize_database_with_slave_script]')

        should contain_exec('remove_synchronize_database_with_slave_script').with({
                'command'     => 'rm -f /var/opt/synchronize_database_with_slave.sh',
                'logoutput'   => 'on_failure',
                'onlyif'      => ['test -f /var/opt/synchronize_database_with_slave.sh'],
        })
    end
  end
end
