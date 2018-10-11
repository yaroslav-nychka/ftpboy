require_relative '../lib/ftp_source'
require_relative '../lib/ftp_dispatcher'

describe 'FTPDispatcher' do

  let(:subject){ Validic::FTPDispatcher.new }
  let(:intervent){ subject.sources[:intervent] }
  let(:intuity){ subject.sources[:intuity] }

  let(:intervent_data_path){ Dir.pwd + '/data/intervent/data'}
  let(:intuity_data_path){ Dir.pwd + '/data/intuity/data/'}

  before(:each) do
    DataCleaner.clean
    intervent.setup!
    intuity.setup!
  end

  after(:each) do
    DataCleaner.clean
  end

  context 'handle' do
    it 'transfers successfully files from one ftp to another' do
      3.times{ |n| DataCreator.touch "data/intervent/data/from/test_#{n}.txt" }

      subject.handle :intervent, :intuity

      expect(intervent.dir.glob('/data/from', '*').length).to eq(0)
      expect(intervent.dir.glob('/data/history', '*').length).to eq(3)
      expect(intuity.dir.glob('/data/to', '*').length).to eq(3)
    end

    it 'transfers files saving folder structure' do
      dirs = %w[claims eligibilities hra]
      seeds = dirs.join('').length
      dirs.map do |dir|
        DataCreator.seed("data/intervent/data/from/Employee_1", dir)
      end

      subject.handle :intervent, :intuity

      expect(intervent.dir.glob('/data/from/', '**/*.*').length).to eq(0)
      expect(intervent.dir.glob('/data/history/', '**/*.*').length).to eq(22)
      expect(intuity.dir.glob('/data/to/', '**/*.*').length).to eq(22)
    end
  end
end
