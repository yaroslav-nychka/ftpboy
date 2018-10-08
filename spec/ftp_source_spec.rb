require_relative '../lib/ftp_source'

describe 'FTPSource' do

  let(:today){ DateTime.now.strftime('%d/%m/%Y') }
  let(:root){ Dir.pwd }
  let(:subject){ FTPSource.new('ftp-temp')}

  def path dir
    "/tmp/#{dir}"
  end

  def root_path dir
    Dir.pwd + "/data/intuity/tmp/" + dir
  end

  context 'opendir' do
    before(:each) do
      #byebug
      subject.mkdir!(path 'bar')
    end

    after(:each) do
      subject.rmdir!(path 'bar') rescue nil
    end

    it 'has response ok' do
      subject.opendir!(path 'bar') do |response|
        expect(response.ok?).to be_truthy
      end
    end

    it 'has response not found' do
      expect{
        subject.opendir!(path 'dir404')
      }.to raise_error(FileTransferError, /Folder not found/)
    end


    it 'has response forbidden' do
      Dir.mkdir(root_path('secret'), 0000) unless Dir.exists? root_path('secret')

      expect{
        subject.opendir!(path('secret'))
      }.to raise_error(FileTransferError, /Permission denied to dir/)

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
end
