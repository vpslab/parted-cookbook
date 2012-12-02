module Parted
  module Utils
    module_function

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
  end
end
