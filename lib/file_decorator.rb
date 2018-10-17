require_relative '../lib/settings'

module InterventFTP
  class FileDecorator
    include Settings
    attr_reader :sftp_file

    FORMAT_SPLITTER = '.'.freeze

    def initialize(sftp_file)
      @sftp_file = sftp_file
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
      @path ||= sftp_file.name
    end

    def basename
      @basename ||= tokens.last
    end

    def dirs
      tokens[0..-2]
    end

    def extension
      @extension ||= basename.split(FORMAT_SPLITTER).last
    end

    def archive_path
      @archive_path ||= "#{archive}/#{dirs.join('/')}/#{archive_basename}"
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
      FileUtils.rm(tmp) if File.exist? tmp
    end

    private

    def tokens
      @tokens ||= path.split('/')
    end

    def archive_basename
      @archived_basename ||= "#{name}_#{Time.now.to_i}#{FORMAT_SPLITTER}#{extension}"
    end
  end
end
