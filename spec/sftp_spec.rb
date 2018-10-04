require_relative '../lib/sftp'

describe 'FileTransfer' do

  let(:today){ DateTime.now.strftime('%d/%m/%Y') }
  let(:root){ Dir.pwd }
  let(:subject){ FileTransfer.new('localhost')}

  def path dir
    "#{root}/tmp/#{dir}"
  end

  context 'opendir' do
    before(:each) do
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
      Dir.mkdir(path('secret'), 0000) unless Dir.exists? path('secret')

      expect{
        subject.opendir!(path('secret'))
      }.to raise_error(FileTransferError, /Permission denied to dir/)

      Dir.rmdir path('secret') if Dir.exists? path('secret')
    end
  end

  context 'logging' do
    xit 'creates log with today date' do
      #File.open(root + '/log/' + today + '.log')
    end
  end
end
