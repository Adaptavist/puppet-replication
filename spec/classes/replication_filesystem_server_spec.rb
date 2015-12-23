require 'spec_helper'
 
describe 'replication::filesystem::server', :type => 'class' do
    
  context "Should include replication filesystem server classes" do
    let :params do
      { :lsync_use_upstart => true,
        :lsync_inotify_watches => 4000,
        :lsync_create_files => {},
        :rsync_modules => {
          'opt' => {
            'type' => 'rsync',
            'source' => '/opt',
            'target' => 'localhost::opt/',
            'init_sync' => false,
            'rsync_verbose' => true,
            'rsync_archive' => true,
            'rsync_hard_links' => true,
            'exclude_from' => '/etc/lsyncd/rsync.exclusions',
            }
          },
        }
    end
    it do
      should contain_class('lsyncd').with({
          'use_upstart' => true,
          'inotify_watches' => 4000,
          'rsync_modules' => {
          'opt' => {
            'type' => 'rsync',
            'source' => '/opt',
            'target' => 'localhost::opt/',
            'init_sync' => false,
            'rsync_verbose' => true,
            'rsync_archive' => true,
            'rsync_hard_links' => true,
            'exclude_from' => '/etc/lsyncd/rsync.exclusions',
            }
          },
          'create_files' => {},
        })
    end
  end
end
