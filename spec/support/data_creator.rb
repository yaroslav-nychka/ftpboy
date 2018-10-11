module DataCreator
  class << self
    def mkdir(dir, mode = nil)
      mode ||= default_mode
      FileUtils.mkdir_p path(dir), mode: mode
    end

    def mkdir!(dir, mode = nil)
      return false if Dir.exists?(path(dir))

      mode ||= default_mode
      mkdir(dir, mode)
    end

    def touch(file)
      File.new "#{root_path}/#{file}", 'w+'
    end

    def seed(path, dir)
      build_filename = ->(n, dir){ "#{dir.slice(0..2)}_#{n}.#{dir.slice(-2..-1)}"}
      mkdir!("#{path}/#{dir}")

      dir.length.times do |n|
        filename = build_filename.call(n, dir)
        touch "#{path}/#{dir}/#{filename}"
      end
    end

    def default_mode
      0777
    end

    def path(path)
      "#{root_path}/#{path}"
    end

    def root_path
      @root_path ||= Dir.pwd
    end
  end
end