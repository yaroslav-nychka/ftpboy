require_relative '../lib/ftp_source'
require_relative '../lib/ftp_dispatcher'

describe 'FTPDispatcher' do

  let(:subject){ Validic::FTPDispatcher.new }
  let(:intervent){ subject.sources[:intervent] }
  let(:intuity){ subject.sources[:intuity] }

  let(:intervent_data_path){ Dir.pwd + '/data/intervent/data'}
  let(:intuity_data_path){ Dir.pwd + '/data/intuity/data/'}

  around(:each) do |each|
    DataCleaner.clean
    each.run
    DataCleaner.clean
  end

  before(:each) do
    intervent.setup!
    intuity.setup!
  end

  context 'handle' do
    it 'transfers successfully files from one ftp to another' do
      FileUtils.cd "#{intervent_data_path}/from" do
        3.times{ |n| FileUtils.touch "test_#{n}.txt" }
      end

      subject.handle :intervent, :intuity

      expect(intervent.dir.glob('/data/from', '*').length).to eq(0)
      expect(intervent.dir.glob('/data/history', '*').length).to eq(3)
      expect(intuity.dir.glob('/data/to', '*').length).to eq(3)
    end
  end
end
