require_relative '../lib/source'
require_relative '../lib/file_decorator'
require_relative '../lib/errors/errors'

describe 'Source' do

  let(:today){ DateTime.now.strftime('%d/%m/%Y') }
  let(:options) do
    {
      host: ENV['INTUITY_FTP_HOST'],
      username: ENV['INTUITY_FTP_USERNAME'],
      password: ENV['INTUITY_FTP_PASSWORD'],
      port: ENV['INTUITY_FTP_PORT']
    }
  end
  subject{ InterventFTP::Source.new('intuity', options)}
  let(:filename){ 'Employee_1/claims/cla_' + Random.rand(10000).to_s + '.ms' }
  let(:file) { InterventFTP::FileDecorator.new double(name: filename) }

  before(:each) do
    DataCleaner.clean
    DataCreator.prepare_dirs_for(subject)
  end

  after(:each) do
    DataCleaner.clean
  end

  context 'opendir' do
    it 'is ok' do
      DataCreator.cd(subject) do
        FileUtils.mkdir 'tmp/bar'
      end

      subject.opendir!('/tmp/bar') do |response|
        expect(response.ok?).to be_truthy
      end
    end

    it 'raises NotFoundError' do
      expect{
        subject.opendir!( '/tmp/dir404')
      }.to raise_error(InterventFTP::NotFoundError)
    end


    it 'raises AccessDeniedError' do
      DataCreator.cd(subject) do
        FileUtils.mkdir 'tmp/secret', mode: 0000
      end

      expect{
        subject.opendir!(('/tmp/secret'))
      }.to raise_error(InterventFTP::AccessDeniedError)
    end
  end

  context 'upload' do
    it 'uploads file saving folder structure' do
      DataCreator.cd do
        FileUtils.mkdir_p 'tmp/Employee_1/claims'
        FileUtils.touch 'tmp/' + filename
      end
      subject.upload! file
      sleep(0.1)

      expect(subject.list_files_for(:receiving).map(&:path)).to match_array([filename])
    end

    it 'raises NotFoundError' do
      expect{
        subject.upload! file
      }.to raise_error(InterventFTP::NotFoundError)
    end

    it 'raises AccessDeniedError' do
      DataCreator.cd do
        FileUtils.mkdir_p 'tmp/Employee_1/claims'
        FileUtils.touch 'tmp/' + filename
      end
      DataCreator.cd(subject) do
        FileUtils.chmod 0000, subject.dir(:receiving)
      end

      expect{
        subject.upload! file
      }.to raise_error(InterventFTP::AccessDeniedError)
    end

    it 'raises NotFoundError' do
      DataCreator.cd do
        FileUtils.mkdir_p 'tmp/Employee_1/claims'
        FileUtils.touch 'tmp/' + filename
      end
      DataCreator.cd(subject) do
        FileUtils.rm_r subject.dir(:receiving)
      end

      expect{
        subject.upload! file
      }.to raise_error(InterventFTP::NotFoundError)
    end
  end

  context 'download' do
    it 'downloads file to tmp' do
      DataCreator.cd(subject) do
        FileUtils.mkdir_p "#{subject.dir(:sending)}/Employee_1/claims"
        FileUtils.touch "#{subject.dir(:sending)}/#{filename}"
      end
      subject.download! file

      expect(File.exist?("#{Dir.pwd}/tmp/#{filename}")).to be_truthy
    end

    it 'raises NotFoundError' do
      DataCreator.cd(subject) do
        FileUtils.mkdir_p "#{subject.dir(:sending)}/Employee_1/claims"
      end

      expect{
        subject.download! file
      }.to raise_error(InterventFTP::NotFoundError)
    end
  end

  context 'list_files_for' do
    it 'is ok' do
      DataCreator.cd subject do
        DataCreator.seed "#{subject.dir(:sending)}/Employee_1", 'hra'
      end
      files = subject.list_files_for(:sending)

      expect(files.length).to eq(3)
    end

    it 'raises NotFoundError' do
      DataCreator.cd(subject) do
        FileUtils.rm_r subject.dir(:archiving)
      end
      expect{
        subject.list_files_for(:archiving)
      }.to raise_error(InterventFTP::NotFoundError)
    end
  end
end
