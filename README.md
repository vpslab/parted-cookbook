Description
===========

Installs parted tool and provides resource for partitioning device in MBR format. Currently only primary partitions are supported.

Usage
=====

    include_recipe 'parted'

    parted '/dev/mapper/vdisk-vm--dummy' do
      layout 'msdos'

      primary :size => '512M', :fstype => 'ext3', :bootable => true
      primary :size => '4G',   :fstype => 'swap'
      primary :size => '20G',  :fstype => 'ext4'

      action [:destroy, :create]
    end

