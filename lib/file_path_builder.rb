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

    def archive
      @archive ||= "#{archive_dir}/#{dirs.join('/')}/#{archived_short}"
    end

    def archived_short
      @archived_short ||= "#{name}_#{Time.now.to_i}#{FORMAT_SPLITTER}#{format}"
    end

    def tmp
      @tmp ||= "#{tmpdir}/#{full}"
    end

    def tmp!
      tmp_path = "#{tmpdir}/#{dirs.join('/')}"
      FileUtils.mkdir_p tmp_path unless Dir.exists? tmp_path
      tmp
    end

    def destroy!
      FileUtils.rm(tmp) if File.exists? tmp
    end

    def archive_dir
      @archive_dir ||= '/data/history'
    end

    def tmpdir
      @tmpdir ||= Dir.pwd + '/tmp'
    end
  end
end
