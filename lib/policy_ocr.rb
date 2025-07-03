module PolicyOcr
  # Validates policy numbers using a checksum algorithm
  #
  # The checksum is calculated as:
  # (d1 + 2*d2 + 3*d3 + ... + 9*d9) mod 11 == 0
  # where d1 is the rightmost digit and d9 is the leftmost digit
  # Formats and validates policy numbers
  module Validator
    # Validates if a policy number has a valid checksum
    #
    # @param number [String, Integer] The policy number to validate
    # @return [Boolean] true if the checksum is valid, false otherwise
    def self.valid_checksum?(number)
      digits = number.to_s.chars.map(&:to_i)
      return false unless digits.size == 9

      sum = digits.each_with_index.sum do |digit, index|
        (9 - index) * digit  # d9*1 + d8*2 + ... + d1*9
      end

      (sum % 11).zero?
    end

    # Calculates the checksum for a policy number
    #
    # @param number [String, Integer] The policy number
    # @return [Integer] The checksum value (0-10)
    def self.calculate_checksum(number)
      # Convert the input to a string, split into individual characters, and map to integers
      digits = number.to_s.chars.map(&:to_i)
      
      # Return nil if the number doesn't have exactly 9 digits
      return nil unless digits.size == 9

      # Calculate the weighted sum where:
      # - First digit (leftmost) is multiplied by 9 (9-0)
      # - Second digit is multiplied by 8 (9-1)
      # - ...
      # - Last digit (rightmost) is multiplied by 1 (9-8)
      sum = digits.each_with_index.sum do |digit, index|
        (9 - index) * digit  # d9*1 + d8*2 + ... + d1*9
      end

      # Return the checksum value (0-10)
      sum % 11
    end

    # Determines the status of a policy number
    # @param number [String] The policy number to check
    # @return [Symbol] :ok, :ill (if contains '?'), or :err (if invalid checksum)
    def self.status(number)
      return :ill if number.include?('?')
      valid_checksum?(number) ? :ok : :err
    end

    # Formats a policy number with its status
    # @param number [String] The policy number to format
    # @return [String] Formatted string with number and status (if not :ok)
    def self.format_number(number)
      status = status(number)
      status == :ok ? number : "#{number} #{status.to_s.upcase}"
    end
  end

  # Handles writing policy number results to files
  class ResultWriter
    # Writes policy number results to a file
    # @param results [Array<Hash>] Array of hashes with :number and :valid_checksum
    # @param output_path [String] Path to write the output file
    def self.write(results, output_path)
      File.open(output_path, 'w') do |file|
        results.each do |result|
          status = if result[:number].include?('?')
                     'ILL'
                   elsif !result[:valid_checksum]
                     'ERR'
                   end
          
          line = result[:number]
          line += " #{status}" if status
          file.puts(line)
        end
      end
    end
  end
  # A parser for OCR (Optical Character Recognition) of policy numbers from ASCII art.
  #
  # The parser reads a text file containing ASCII art representations of numbers,
  # where each digit is represented by a 3x3 grid of characters using '_', '|', and spaces.
  #
  # File format:
  # - Each entry consists of 4 lines: 3 lines of ASCII art followed by a blank line
  # - Each line is 27 characters long, representing 9 digits (3 characters per digit)
  # - Example entry for the number "000000000":
  #     _  _  _  _  _  _  _  _  _ 
  #   | || || || || || || || || |
  #   |_||_||_||_||_||_||_||_||_|
  #   
  class Parser
    # Maps ASCII art patterns to their corresponding digits.
    # Each key is an array of 3 strings representing the 3 lines of a digit.
    DIGIT_MAP = {
      [" _ ",
       "| |",
       "|_|"] => '0',
      ["   ",
       "  |",
       "  |"] => '1',
      [" _ ",
       " _|",
       "|_ "] => '2',
      [" _ ",
       " _|",
       " _|"] => '3',
      ["   ",
       "|_|",
       "  |"] => '4',
      [" _ ",
       "|_ ",
       " _|"] => '5',
      [" _ ",
       "|_ ",
       "|_|"] => '6',
      [" _ ",
       "  |",
       "  |"] => '7',
      [" _ ",
       "|_|",
       "|_|"] => '8',
      [" _ ",
       "|_|",
       " _|"] => '9'
    }.freeze

    # Initializes a new Parser instance.
    #
    # @param file_path [String, nil] Path to the file containing OCR data.
    #   Defaults to 'spec/fixtures/sample.txt' if not provided.
    def initialize(file_path = nil)
      @file_path = file_path || 'spec/fixtures/sample.txt'
    end

    # Parses the OCR file and returns an array of policy number hashes with validation status
    #
    # @return [Array<Hash>] An array of hashes with :number and :valid_checksum keys
    # @raise [ArgumentError] If the file does not exist
    # @raise [StandardError] If there are permission issues or the file is empty
    def parse
      raise ArgumentError, "File not found: #{@file_path}" unless File.exist?(@file_path)

      lines = File.readlines(@file_path, chomp: true)
      raise StandardError, "File is empty: #{@file_path}" if lines.empty?

      lines.each_slice(4).map do |entry_lines|
        entry_lines = entry_lines.take(3) # Only take the first 3 lines in case of missing newline at EOF
        next nil unless entry_lines.size == 3
        
        number = parse_ascii_digit_lines(entry_lines)
        {
          number: number,
          valid_checksum: Validator.valid_checksum?(number)
        }
      end.compact
    rescue Errno::EACCES => e
      raise StandardError, "Permission denied when reading file: #{@file_path}"
    rescue => e
      raise StandardError, "Error reading file #{@file_path}: #{e.message}"
    end

    private

    # Parses ASCII art lines into a string of digits.
    #
    # @param lines [Array<String>] An array of 3 strings, each representing a line of ASCII art.
    # @return [String] A 9-digit string with '?' for any unrecognized digits.
    def parse_ascii_digit_lines(lines)
      (0...27).step(3).map do |i|
        digit_pattern = lines.map { |line| line[i, 3] || '   ' }
        DIGIT_MAP[digit_pattern] || '?'
      end.join
    end
  end
end
