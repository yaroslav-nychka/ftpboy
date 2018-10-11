module Validic
  class FilePathBuilder
    attr_reader :file

    FORMAT_SPLITTER = '.'.freeze

    def initialize(file)
      @file = file
    end

    def name
      until @name
        name = short.clone
        name.slice!(-(format.length + 1)..-1)
        @name = name
      end
      @name
    end

    def full
      @full ||= file.name
    end

    def short
      @short ||= tokens.last
    end

    def tokens
      @tokens ||= full.split('/')
    end

    def dirs
      tokens[0..-2]
    end

    def format
      @format ||= short.split(FORMAT_SPLITTER).last
    end

    def to
      @to ||= "#{receiver_dir}/#{short}"
    end

    def from
      @from ||= "#{sender_dir}/#{short}"
    end

    def archive
      @archive ||= "/data/history/#{archived_short}"
    end

    def archived_short
      @archived_short ||= "#{name}_#{Time.now.to_i}#{FORMAT_SPLITTER}#{format}"
    end

    def tmp
      @tmp ||= "#{tmpdir}/#{short}"
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
