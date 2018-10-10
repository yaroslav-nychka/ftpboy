require_relative '../lib/ftp_source'

describe 'FTPSource' do

  let(:today){ DateTime.now.strftime('%d/%m/%Y') }
  let(:options) do
    {
      host: ENV['INTUITY_FTP_HOST'],
      username: ENV['INTUITY_FTP_USERNAME'],
      password: ENV['INTUITY_FTP_PASSWORD'],
      port: ENV['INTUITY_FTP_PORT']
    }
  end
  let(:subject){ Validic::FTPSource.new('intuity-test', options)}

  around(:each) do |each|
    DataCleaner.clean
    each.run
    DataCleaner.clean
  end

  context 'opendir' do
    before(:each) do
      DataCreator.mkdir!('data/intuity/tmp/bar')
    end

    it 'has response ok' do
      subject.opendir!('/tmp/bar') do |response|
        expect(response.ok?).to be_truthy
      end
    end

    it 'has response not found' do
      expect{
        subject.opendir!( '/tmp/dir404')
      }.to raise_error(Validic::FileTransferError, /Folder not found/)
    end


    it 'has response forbidden' do
      DataCreator.mkdir!('/data/intuity/tmp/secret', 644)

      expect{
        subject.opendir!(('/tmp/secret'))
      }.to raise_error(Validic::FileTransferError, /Permission denied to dir/)
    end
  end

  context 'upload' do
    before(:each) do
      DataCleaner.clean
    end

    it 'has response ok' do
      DataCreator.touch 'tmp/foo.txt'

      local_path = "#{Dir.pwd}/tmp/foo.txt"
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
    before(:each) do
      subject.setup!
    end

    it 'has no new files' do
      expect(subject.new_data?).to be_falsey
    end

    it 'has 2 files' do
      DataCreator.touch 'data/intuity/data/from/test1.txt'
      DataCreator.touch 'data/intuity/data/from/test2.txt'

      expect(subject.new_data?).to eq(2)
    end
  end
end
