require_relative '../lib/ftp_source'

describe 'FTPSource' do

  let(:today){ DateTime.now.strftime('%d/%m/%Y') }
  let(:root){ Dir.pwd }
  let(:options) do
    {
      host: ENV['INTUITY_FTP_HOST'],
      username: ENV['INTUITY_FTP_USERNAME'],
      password: ENV['INTUITY_FTP_PASSWORD'],
      port: ENV['INTUITY_FTP_PORT']
    }
  end
  let(:subject){ Validic::FTPSource.new('intuity-test', options)}

  def path dir
    "/tmp/#{dir}"
  end

  def root_path dir
    Dir.pwd + "/data/intuity/tmp/" + dir
  end

  context 'opendir' do
    before(:each) do
      FileUtils.mkdir "#{Dir.pwd}/data/intuity/tmp/bar"
    end

    after(:each) do
      FileUtils.rmdir "#{Dir.pwd}/data/intuity/tmp/bar"
    end

    it 'has response ok' do
      subject.opendir!(path 'bar') do |response|
        expect(response.ok?).to be_truthy
      end
    end

    it 'has response not found' do
      expect{
        subject.opendir!(path 'dir404')
      }.to raise_error(Validic::FileTransferError, /Folder not found/)
    end


    it 'has response forbidden' do
      Dir.mkdir(root_path('secret'), 0000) unless Dir.exists? root_path('secret')

      expect{
        subject.opendir!(path('secret'))
      }.to raise_error(Validic::FileTransferError, /Permission denied to dir/)

      Dir.rmdir root_path('secret') if Dir.exists? root_path('secret')
    end
  end

  context 'upload' do
    before(:each) do
      FileUtils.rm_r Dir.glob(Dir.pwd + '/tmp/*')
    end

    it 'has response ok' do
      FileUtils.cd(root + '/tmp'){ FileUtils.touch 'foo.txt' }
      local_path = "#{root}/tmp/foo.txt"
      remote_path = "/tmp/foo.txt"

      subject.upload!(local_path, remote_path) do |response|
        expect(response.ok?).to be_truthy
      end
      expect(subject.dir.glob('/tmp', '*.txt').first.name).to eq('foo.txt')
    end
  end

  context 'setup' do
    before(:each) do
      subject.setup!
    end

    it 'has correct schema' do
      files = subject.dir.glob('/data', '*')
      expect(files.map(&:name)).to match_array(%w(to from history))
    end
  end

  context 'new data availability' do
    let(:ftp_path){  Dir.pwd + '/data/intuity/data/from/'}

    before(:each) do
      subject.setup!
    end

    after(:each) do
      FileUtils.rm_r Dir.glob(ftp_path + '*')
    end

    it 'has no new files' do
      expect(subject.new_data?).to be_falsey
    end

    it 'has 2 files' do
      FileUtils.cd ftp_path do
        FileUtils.touch 'test1.txt'
        FileUtils.touch 'test2.txt'
      end

      expect(subject.new_data?).to eq(2)
    end
  end
end
