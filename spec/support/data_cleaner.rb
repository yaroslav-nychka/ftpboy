module DataCleaner
  class << self
    def clean
      %W(
        #{Dir.pwd}/data/intervent/data/
        #{Dir.pwd}/data/intuity/data/
        #{Dir.pwd}/data/intuity/tmp/
        #{Dir.pwd}/data/intervent/tmp/
        #{Dir.pwd}/tmp/
      ).map {|path| FileUtils.rm_rf Dir.glob(path +  '*')}
    end
  end
end