require 'spec_helper'
require 'tempfile'
require_relative '../lib/policy_ocr'

RSpec.describe PolicyOcr::ResultWriter do
  describe '.write' do
    let(:results) do
      [
        { number: '457508000', valid_checksum: true },
        { number: '664371495', valid_checksum: false },
        { number: '86110??36', valid_checksum: false },
        { number: '123456789', valid_checksum: true }
      ]
    end
    
    let(:expected_output) do
      <<~OUTPUT
        457508000
        664371495 ERR
        86110??36 ILL
        123456789
      OUTPUT
    end
    
    it 'writes the results to a file with correct formatting' do
      Tempfile.create('output') do |tempfile|
        described_class.write(results, tempfile.path)
        
        # Read the file and normalize line endings
        file_content = File.read(tempfile.path).gsub(/\r\n?/, "\n")
        
        # Compare each line to handle potential trailing newline differences
        expected_lines = expected_output.split("\n")
        actual_lines = file_content.split("\n")
        
        expected_lines.each_with_index do |expected_line, i|
          expect(actual_lines[i]).to eq(expected_line)
        end
      end
    end
    
    it 'creates the output file if it does not exist' do
      temp_path = "#{Dir.tmpdir}/policy_results_#{Time.now.to_i}.txt"
      begin
        described_class.write(results, temp_path)
        expect(File.exist?(temp_path)).to be true
      ensure
        File.delete(temp_path) if File.exist?(temp_path)
      end
    end
    
    it 'overwrites existing files without appending' do
      Tempfile.create('output') do |tempfile|
        # Write initial content
        tempfile.write("old content")
        tempfile.close
        
        # Write results
        described_class.write(results, tempfile.path)
        
        # Should not contain the old content
        file_content = File.read(tempfile.path)
        expect(file_content).not_to include("old content")
        expect(file_content).to include("457508000")
      end
    end
  end
end
