
class FTPDispatcher
  attr_reader :sources

  def initialize
    @sources = {}
    @sources[:intervent] = FTPSource.new('INTERVENT', username: 'intervent', password: 'pass', port: '8888')
    @sources[:intuity] = FTPSource.new('INTUITY', username: 'intuity', password: 'pass', port: '7777')
  end

  def handle(from, to)
    source_from = sources[from]
    source_to = sources[to]

    source_from.dir.glob('/data/from', '*').map do |file|
      path = FilePathBuilder.new(file)
      # 1. Download file to temp folder
      source_from.download! path.from, path.tmp
      # 2. Upload tempfile
      source_to.upload! path.tmp, path.to
      # 3. Move file to History folder
      source_from.rename! path.from, path.archive
      # 4. Remove file from temp folder
      FileUtils.rm path.tmp
    end
  end
end

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
    "#{receiver_dir}/#{filename}"
  end

  def from
    "#{sender_dir}/#{filename}"
  end

  def archive
    "/data/history/#{archived_filename}"
  end

  def archived_filename
    @archived_filename ||= "#{name}_#{Time.now.to_i}#{FORMAT_SPLITTER}#{format}"
  end

  def tmp
    "#{tmpdir}/#{filename}"
  end

  def sender_dir
    @sender_dir ||= '/data/from'
  end

  def receiver_dir
    @receiver_dir ||= '/data/to'
  end

  def tmpdir
    Dir.pwd + '/tmp'
  end
end
