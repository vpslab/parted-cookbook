action :create do
  if blank_disk?
    start_sector = 2048
    new_resource.primary_partitions.each_with_index do |partition, index|
      partition_device = "#{new_resource.device}#{index + 1}"
      end_sector = start_sector + size_in_sectors(partition.size) - 1

      create_partition_resource(:run, partition_device, start_sector, end_sector)
      format_partition_resource(:run, partition_device, partition.fstype)
      set_bootable_partition_resource(:run, partition_device) if partition.bootable

      start_sector = end_sector + 1
    end
  end
end

action :destroy do
  clear_partition_table_resource(:run) unless blank_disk?
end

def blank_disk?
  `parted -m #{new_resource.device} print`.split($/).size < 3
end

def clear_partition_table_resource(exec_action)
  r = execute "clear #{new_resource.layout} partition table on #{new_resource.device}" do
    command "parted -s #{new_resource.device} mklabel #{new_resource.layout}"
    action :nothing
  end
  r.run_action(exec_action)
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
end

def create_partition_resource(exec_action, partition_device, start_sector, end_sector)
  r = execute "create partition #{partition_device}" do
    command "parted -s #{new_resource.device} unit s mkpart primary #{start_sector} #{end_sector}"
    creates partition_device
    action :nothing
  end
  r.run_action(exec_action)
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
end

def set_bootable_partition_resource(exec_action, partition_device)
  partition_index = partition_device.sub(new_resource.device, '')
  r = execute "set partition bootable #{partition_device}" do
    command "parted -s #{new_resource.device} set #{partition_index} boot on"
    action :nothing
  end
  r.run_action(exec_action)
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
end

def format_partition_resource(exec_action, partition_device, fstype)
  tool = case fstype
         when /swap/
          "mkswap"
         else
          "mkfs.#{fstype}"
        end

  r = execute "format partition #{partition_device}" do
    command "#{tool} #{partition_device}"
    action :nothing
  end
  r.run_action(exec_action)
  new_resource.updated_by_last_action(true) if r.updated_by_last_action?
end

def size_in_sectors(value)
  sector_size = 512
  alignment   = 1024
  case value
  when /M$/ then value.to_i * 1000 * alignment / sector_size
  when /G$/ then value.to_i * 1000 * 1000 * alignment / sector_size
  when /s/  then value.to_i
  else
    raise "Could not convert #{value} to sectors"
  end
end
