module Validic
  class FilePathBuilder
    attr_reader :file

    FORMAT_SPLITTER = '.'.freeze

    def initialize(file)
      @file = file
    end

    def name
      until @name
        name = filename.clone
        name.slice!(-(format.length + 1)..-1)
        @name = name
      end
      @name
    end

    def filename
      @filename ||= file.name
    end

    def format
      @format ||= filename.split(FORMAT_SPLITTER).last
    end

    def to
      @to ||= "#{receiver_dir}/#{filename}"
    end

    def from
      @from ||= "#{sender_dir}/#{filename}"
    end

    def archive
      @archive ||= "/data/history/#{archived_filename}"
    end

    def archived_filename
      @archived_filename ||= "#{name}_#{Time.now.to_i}#{FORMAT_SPLITTER}#{format}"
    end

    def tmp
      @tmp ||= "#{tmpdir}/#{filename}"
    end

    def sender_dir
      @sender_dir ||= '/data/from'
    end

    def receiver_dir
      @receiver_dir ||= '/data/to'
    end

    def tmpdir
      @tmpdir ||= Dir.pwd + '/tmp'
    end
  end
end
