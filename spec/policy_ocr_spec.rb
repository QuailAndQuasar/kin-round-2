require_relative 'spec_helper'
require_relative '../lib/policy_ocr'

describe PolicyOcr do
  it "is a module" do
    expect(PolicyOcr).to be_a Module
  end

  describe 'Parser' do
    let(:sample_file) { File.expand_path('fixtures/sample.txt', __dir__) }
    let(:parser) { PolicyOcr::Parser.new(sample_file) }
    
    # Test digit parsing
    describe 'digit recognition' do
      let(:parser) { PolicyOcr::Parser.new }
      
      it 'recognizes all digits' do
        digits = {
          [" _ ", "| |", "|_|"] => '0',
          ["   ", "  |", "  |"] => '1',
          [" _ ", " _|", "|_ "] => '2',
          [" _ ", " _|", " _|"] => '3',
          ["   ", "|_|", "  |"] => '4',
          [" _ ", "|_ ", " _|"] => '5',
          [" _ ", "|_ ", "|_|"] => '6',
          [" _ ", "  |", "  |"] => '7',
          [" _ ", "|_|", "|_|"] => '8',
          [" _ ", "|_|", " _|"] => '9'
        }
        
        digits.each do |pattern, expected_digit|
          # Create a full line for each digit by repeating its pattern
          full_line = pattern.map { |line| line * 9 }
          # The method processes all digits in the line, so we expect 9 of the same digit
          expect(parser.send(:parse_ascii_digit_lines, full_line)).to eq(expected_digit * 9)
        end
      end
      
      it 'returns ? for unrecognized patterns' do
        invalid_pattern = ["   ", "   ", "   "] * 9
        expect(parser.send(:parse_ascii_digit_lines, invalid_pattern)).to include('?')
      end
    end
    
    # Test file handling
    describe 'file handling' do
      it 'loads the sample file' do
        expect(File.exist?(sample_file)).to be true
      end
      
      it 'raises error for non-existent file' do
        expect { PolicyOcr::Parser.new('nonexistent.txt').parse }.to raise_error(StandardError, /File not found/)
      end
      
      it 'raises error for empty file' do
        empty_file = File.expand_path('fixtures/empty.txt', __dir__)
        File.write(empty_file, '')
        expect { PolicyOcr::Parser.new(empty_file).parse }.to raise_error(StandardError, /File is empty/)
        File.delete(empty_file) if File.exist?(empty_file)
      end
    end
    
    # Test parsing functionality
    describe 'parsing' do
      it 'returns an array of strings' do
        entries = parser.parse
        expect(entries).to be_an(Array)
        expect(entries).to all(be_a(String))
      end
      
      it 'handles files with missing trailing newline' do
        content = " _  _  _  _  _  _  _  _  _ \n| || || || || || || || || |\n|_||_||_||_||_||_||_||_||_|"
        temp_file = File.expand_path('fixtures/temp.txt', __dir__)
        File.write(temp_file, content)
        
        expect {
          entries = PolicyOcr::Parser.new(temp_file).parse
          expect(entries).to eq(['000000000'])
        }.to_not raise_error
        
        File.delete(temp_file) if File.exist?(temp_file)
      end
    end
  end
end
