require 'ostruct'

actions :create, :destroy

def initialize *args
  super
  @primary_partitions = []
  @action = :create
end

attribute :device, :kind_of => String, :name_attribute => true
attribute :layout, :kind_of => [String, Symbol], :default => 'msdos'

def primary(partition)
  validate({:primary =>  partition}, {:primary => {:kind_of => Hash}})
  @primary_partitions << ::OpenStruct.new(partition)
end

def primary_partitions
  @primary_partitions
end

def bootable_partitions
  primary_partitions.select { |p| p.boot }
end
