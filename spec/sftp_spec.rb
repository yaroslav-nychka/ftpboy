require_relative '../lib/sftp'

describe 'FileTransfer' do

  let(:subject){ FileTransfer.new('localhost', 'yaroslav_nychka', 'Srdk07dap!:D')}

  before(:each) do
    subject.sftp.opendir! 'Trash'
    subject.sftp.rmdir!('foo1') rescue nil
  end

  it 'creates dir with response ok' do
    subject.sftp.mkdir! 'foo1'

    subject.sftp.opendir!('foo1') do |response|
      expect(response.ok?).to be_truthy
    end
  end

  it 'creates dir with exception' do
    subject.mkdir 'foo1'

    expect{subject.mkdir('foo1')}.to raise_error(FileTransferError, /Could not create dir/)
  end
end
