module DataCreator
  class << self
    def cd(source = nil, &block)
      chdir = source ? source_path(source) : root_path
      FileUtils.cd(chdir, &block)
    end

    def seed(path, dir)
      build_filename = ->(n, dir){ "#{dir.slice(0..2)}_#{n}.#{dir.slice(-2..-1)}"}
      FileUtils.mkdir_p "#{path}/#{dir}" unless Dir.exist?("#{path}/#{dir}")

      dir.length.times do |n|
        filename = build_filename.call(n, dir)
        FileUtils.touch "#{path}/#{dir}/#{filename}"
      end
    end

    def prepare_dirs_for(source)
      source.settings['dirs']['remote'].values.map do |dir|
        dir_path = path("data/#{source.name}/#{dir}")
        FileUtils.mkdir_p(dir_path, mode: 0777) unless Dir.exist?(dir_path)
      end
    end

    def source_path(source)
      "#{root_path}/data/#{source.name}/"
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
