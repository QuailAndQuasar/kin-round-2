require_relative '../lib/policy_ocr'

describe PolicyOcr do
  it "is a module" do
    expect(PolicyOcr).to be_a Module
  end

  describe 'Parser' do
    let(:sample_file) { File.expand_path('fixtures/sample.txt', __dir__) }
    let(:parser) { PolicyOcr::Parser.new(sample_file) }

    it 'loads the sample file' do
      expect(File.exist?(sample_file)).to be true
    end

    it 'parses the sample file' do
      entries = parser.parse
      expect(entries).to be_an(Array)
      expect(entries).not_to be_empty
      expect(entries.first).to be_a(String)
    end
  end
end
