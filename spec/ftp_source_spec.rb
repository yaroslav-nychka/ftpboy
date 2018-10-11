require_relative '../lib/ftp_source'
require_relative '../lib/file_path_builder'

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
  let(:subject){ Validic::FTPSource.new('intuity', options)}
  let(:filename){ 'Employee_1/claims/cla_01.ms' }
  let(:file) { Validic::FilePathBuilder.new double(name: filename) }

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
    it 'uploads file saving folder structure' do
      DataCreator.mkdir 'tmp/Employee_1/claims'
      DataCreator.touch 'tmp/' + filename

      subject.upload! file

      expect(subject.dir.glob('/data/to', '**/*.*').map(&:name)).to match_array([filename])
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

  context 'download' do
    it 'downloads file to tmp' do
      DataCreator.mkdir("data/intuity/data/from/Employee_1/claims")
      DataCreator.touch("data/intuity/data/from/#{filename}")

      subject.download! file

      expect(File.exists?"#{Dir.pwd}/tmp/#{filename}").to be_truthy
    end
  end
end
