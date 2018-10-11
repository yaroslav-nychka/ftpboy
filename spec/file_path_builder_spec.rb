require_relative '../lib/file_path_builder'

describe 'FilePathBuilder' do
  let(:filename){ 'Employee_1/claims/cla_01.ms' }
  let(:subject){ Validic::FilePathBuilder.new double(name: filename)}

  it '#format' do
    expect(subject.format).to eq('ms')
  end

  it '#name' do
    expect(subject.name).not_to match(/.\.ms$/)
  end

  it '#short' do
    expect(subject.short).to eq('cla_01.ms')
  end

  it '#full' do
    expect(subject.full).to eq(filename)
  end

  it '#dirs' do
    expect(subject.dirs).to match_array(['Employee_1', 'claims'])
  end

  it '#tmp' do
    expect(subject.tmp!).to eq("#{subject.tmpdir}/#{filename}")
  end

  it '#tmp!' do
    subject.tmp!
    expect(Dir.exists? "#{subject.tmpdir}/Employee_1/claims").to be_truthy
  end

  it '#from' do
    expect(subject.from).to eq("#{subject.sender_dir}/#{filename}")
  end

  it '#to' do
    expect(subject.to).to eq("#{subject.receiver_dir}/#{filename}")
  end
end
