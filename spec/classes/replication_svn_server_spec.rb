require 'spec_helper'
 
describe 'replication::svn::server', :type => 'class' do
    
  context "Should include replication svn" do
    let :params do
      { :sync_username => 'user',
        :sync_password => 'pass',
        :source_username => 'user',
        :source_password => 'pass',
        :repo_location => '/tmp/repo'
        }
    end
    it do
      should contain_class('subversion')
      should contain_file('svn_post_commit_hook_template').with({
        'ensure'  => 'file',
        'path'    => "/tmp/repo/hooks/post-commit",
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        })
    end
  end
end
