require 'spec_helper'
require_relative '../lib/policy_ocr'

describe PolicyOcr::Validator do
  describe '.valid_checksum?' do
    it 'returns true for valid policy numbers' do
      # Example from the checksum formula: 3 4 5 8 8 2 8 6 5
      # (5*1 + 6*2 + 8*3 + 2*4 + 8*5 + 8*6 + 5*7 + 4*8 + 3*9) % 11 = 0
      expect(described_class.valid_checksum?(345882865)).to be true
      
      # Another valid example: 123456789
      # (9*1 + 8*2 + 7*3 + 6*4 + 5*5 + 4*6 + 3*7 + 2*8 + 1*9) % 11 = 0
      expect(described_class.valid_checksum?('123456789')).to be true
    end

    it 'returns false for invalid policy numbers' do
      # Invalid checksum
      expect(described_class.valid_checksum?(111111111)).to be false
      expect(described_class.valid_checksum?('123456788')).to be false
    end

    it 'returns false for numbers with incorrect length' do
      expect(described_class.valid_checksum?(12345678)).to be false    # too short
      expect(described_class.valid_checksum?('1234567890')).to be_falsey # too long
    end

    it 'handles string input' do
      expect(described_class.valid_checksum?('345882865')).to be true
    end
  end

  describe '.calculate_checksum' do
    it 'returns the correct checksum value' do
      expect(described_class.calculate_checksum(345882865)).to eq(0)  # valid checksum (sum % 11 == 0)
      expect(described_class.calculate_checksum(111111111)).to eq(1)  # 45 % 11 = 1
      expect(described_class.calculate_checksum('123456789')).to eq(0) # valid checksum (sum % 11 == 0)
    end

    it 'returns nil for numbers with incorrect length' do
      expect(described_class.calculate_checksum(12345678)).to be_nil
      expect(described_class.calculate_checksum('1234567890')).to be_nil
    end
  end
end
