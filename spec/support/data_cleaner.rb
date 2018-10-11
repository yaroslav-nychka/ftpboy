module DataCleaner
  class << self
    def clean
      %W(
        #{Dir.pwd}/data/intervent/data/from/
        #{Dir.pwd}/data/intervent/data/to/
        #{Dir.pwd}/data/intuity/data/from/
        #{Dir.pwd}/data/intuity/data/to/
        #{Dir.pwd}/data/intuity/data/history/
        #{Dir.pwd}/data/intuity/tmp/
        #{Dir.pwd}/data/intervent/tmp/
        #{Dir.pwd}/data/intervent/data/history/
        #{Dir.pwd}/tmp/
      ).map {|path| FileUtils.rm_rf Dir.glob(path + '*')}
    end
  end
end