require_relative '../lib/source'
require_relative '../lib/dispatcher'

describe InterventFTP::Dispatcher do
  let(:intervent){ subject.sources[:intervent] }
  let(:intuity){ subject.sources[:intuity] }

  before(:each) do
    DataCleaner.clean
    DataCreator.prepare_dirs_for(intervent)
    DataCreator.prepare_dirs_for(intuity)
  end

  after(:each) do
    DataCleaner.clean
  end

  context 'handle' do
    it 'transfers successfully files from one ftp to another' do
      DataCreator.cd(intervent) do
        3.times{|n| FileUtils.touch "#{intervent.dir(:sending)}/test_#{n}.txt"}
      end

      subject.handle :intervent, :intuity

      expect(intervent.list_files_for(:sending).length).to eq(0)
      expect(intervent.list_files_for(:archiving).length).to eq(3)
      expect(intuity.list_files_for(:receiving).length).to eq(3)
    end

    it 'transfers files saving folder structure' do
      dirs = %w[claims eligibilities hra]
      seeds = dirs.join('').length
      DataCreator.cd(intervent) do
        dirs.map do |dir|
          DataCreator.seed("#{intervent.dir(:sending)}/Employee_1", dir)
        end
      end

      subject.handle :intervent, :intuity

      expect(intervent.list_files_for(:sending).length).to eq(0)
      expect(intervent.list_files_for(:archiving).length).to eq(seeds)
      expect(intuity.list_files_for(:receiving).length).to eq(seeds)
    end
  end
end
