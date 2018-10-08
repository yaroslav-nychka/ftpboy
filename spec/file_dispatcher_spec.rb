
describe 'FileDispatcher' do

  let(:intervent){ FTPSource.new('INTERVENT', username: 'intervent', password: 'pass', port: '8888')}
  let(:intuity){ FTPSource.new('INTUITY', username: 'intuity', password: 'pass', port: '7777')}

  it 'dispatches file from one ftp source to another' do

  end
end
