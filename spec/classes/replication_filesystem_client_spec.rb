require 'spec_helper'
 
describe 'replication::filesystem::client', :type => 'class' do
    
  context "Should include replication filesystem" do
    let :params do
      { 
        :folders => {
            'opt' => {
                'path' => '/opt',  
                'comment' => 'Opt DR sync',
                'read_only' => 'no',
                'list' => 'yes',
                'uid' => 'root',
                'gid' => 'root',
            }
        },
        :create_folders => {
            '/opt' => {
                'ensure' => 'file',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0744',
            }
        }
      }
    end
    let(:facts) {
     { :osfamily     => 'RedHat' }
    }
    it do
      should contain_rsync__server__module('opt').with({
        'path' => '/opt',  
        'comment' => 'Opt DR sync',
        'read_only' => 'no',
        'list' => 'yes',
        'uid' => 'root',
        'gid' => 'root',
        })

      should contain_file('/opt').with({
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0744',
        })

    end
  end
end
