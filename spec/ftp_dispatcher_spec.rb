require_relative '../lib/ftp_source'
require_relative '../lib/ftp_dispatcher'

describe 'FTPDispatcher' do

  let(:subject){ FTPDispatcher.new }
  let(:intervent){ FTPSource.new('intervent', username: 'intervent', password: 'pass', port: '8888')}
  let(:intuity){ FTPSource.new('intuity', username: 'intuity', password: 'pass', port: '7777')}

  let(:intervent_data_path){ Dir.pwd + '/data/intervent/data'}
  let(:intuity_data_path){ Dir.pwd + '/data/intuity/data/'}

  before(:each) do
    intervent.setup!
    intuity.setup!
    clean
  end

  after(:each) do
    clean
  end

  it 'dispatches file from one ftp source to another' do

    FileUtils.cd "#{intervent_data_path}/from" do
      3.times{ |n| FileUtils.touch "test_#{n}.txt" }
    end

    subject.handle :intervent, :intuity

    expect(intuity.dir.glob('/data/to', '*').length).to eq(3)
  end

  private

  def clean
    %W(
      #{Dir.pwd}/data/intervent/data/from/
      #{Dir.pwd}/data/intervent/data/to/
      #{Dir.pwd}/data/intuity/data/from/
      #{Dir.pwd}/data/intuity/data/to/
      #{Dir.pwd}/data/intuity/data/history/
      #{Dir.pwd}/data/intuity/tmp/
      #{Dir.pwd}/data/intervent/tmp/
      #{Dir.pwd}/data/intervent/data/history/
    ).map {|path| FileUtils.rm_r Dir.glob(path + '*')}
  end
end
