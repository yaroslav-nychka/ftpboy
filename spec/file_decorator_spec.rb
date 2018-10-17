require_relative '../lib/file_decorator'
require_relative '../lib/../lib/settings'

describe 'FileDecorator' do
  let(:filename){ 'Employee_1/claims/cla_01.ms' }
  subject{ InterventFTP::FileDecorator.new double(name: filename)}

  describe '#extension' do
    it 'returns correct extension' do
      expect(subject.extension).to eq('ms')
    end
  end

  describe '#name' do
    it 'is basename without extension' do
      expect(subject.name).not_to match(/.\.ms$/)
    end
  end

  describe '#basename' do
    it 'is name plus extension' do
      expect(subject.basename).to eq('cla_01.ms')
    end
  end

  describe '#path' do
    it 'is relative path' do
      expect(subject.path).to eq(filename)
    end
  end

  describe '#dirs' do
    it 'returns dirs from path' do
      expect(subject.dirs).to match_array(['Employee_1', 'claims'])
    end
  end

  describe '#tmp' do
    it 'returns temporary path' do
      expect(subject.tmp!).to eq("#{subject.tmpdir}/#{filename}")
    end
  end

  describe '#tmp!' do
    it 'creates dirs according path and returns temporary path' do
      subject.tmp!
      expect(Dir.exists? "#{subject.tmpdir}/Employee_1/claims").to be_truthy
    end
  end

  describe '#destroy!' do
    it 'removes temporary file' do
      DataCreator.cd do
        FileUtils.mkdir_p 'tmp/Employee_1/claims'
        FileUtils.touch "tmp/#{filename}"
      end

      subject.destroy!

      expect(File.exists?(subject.tmp)).to be_falsey
    end
  end
end
