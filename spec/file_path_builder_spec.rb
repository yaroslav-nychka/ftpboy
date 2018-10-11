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
end