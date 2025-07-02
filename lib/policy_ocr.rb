module PolicyOcr
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
    }.freeze

    # Initializes a new Parser instance.
    #
    # @param file_path [String, nil] Path to the file containing OCR data.
    #   Defaults to 'spec/fixtures/sample.txt' if not provided.
    def initialize(file_path = nil)
      @file_path = file_path || 'spec/fixtures/sample.txt'
    end

    def parse
      raise ArgumentError, "File not found: #{@file_path}" unless File.exist?(@file_path)

      lines = File.readlines(@file_path, chomp: true)
      raise StandardError, "File is empty: #{@file_path}" if lines.empty?

      lines.each_slice(4).map do |entry_lines|
        entry_lines = entry_lines.take(3) # Only take the first 3 lines in case of missing newline at EOF
        entry_lines.size == 3 ? parse_ascii_digit_lines(entry_lines) : nil
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
