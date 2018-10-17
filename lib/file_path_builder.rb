module Validic
  class FilePathBuilder
    attr_reader :file

    FORMAT_SPLITTER = '.'.freeze

    def initialize(file)
      @file = file
    end

    def name
      until @name
        name = basename.clone
        name.slice!(-(extension.length + 1)..-1)
        @name = name
      end
      @name
    end

    def path
      @path ||= file.name
    end

    def basename
      @basename ||= tokens.last
    end

    # private
    def tokens
      @tokens ||= path.split('/')
    end

    def dirs
      tokens[0..-2]
    end

    def extension
      # File.basename(basename, ".*")
      @extension ||= basename.split(FORMAT_SPLITTER).last
    end

    def archive
      @archive ||= "#{archive_dir}/#{dirs.join('/')}/#{archived_basename}"
    end

    def archived_basename
      @archived_basename ||= "#{name}_#{Time.now.to_i}#{FORMAT_SPLITTER}#{extension}"
    end

    def tmp
      @tmp ||= "#{tmpdir}/#{path}"
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
