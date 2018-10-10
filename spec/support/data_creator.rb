module DataCreator
  class << self
    def mkdir(dir, mode = nil)
      mode ||= default_mode
      FileUtils.mkdir path(dir), mode: mode
    end

    def mkdir!(dir, mode = nil)
      return false if Dir.exists?(path(dir))

      mode ||= default_mode
      mkdir(dir, mode)
    end

    def touch(file)
      FileUtils.touch "#{root_path}/#{file}"#}
    end

    def default_mode
      777
    end

    def path(path)
      "#{root_path}/#{path}"
    end

    def root_path
      @root_path ||= Dir.pwd
    end
  end
end