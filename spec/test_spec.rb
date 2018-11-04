describe 'test describe' do
  it 'test it pass' do
    actual = 1
    expect(actual).to eq(1)
  end

  it 'test it fail' do
    actual = 0
    expect(actual).to eq(1)
  end
end
