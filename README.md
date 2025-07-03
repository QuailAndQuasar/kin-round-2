# kin-round-2
Round 2 for Kin programming challenge

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kin-round-2'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install kin-round-2
```

## Usage

```bash
bundle exec exe/policy_ocr
```


## User Story 1

Write a program that can take this file and parse it into actual numbers.

Input: A file with ASCII art numbers
Output: A string of numbers

Example:
Input: spec/fixtures/sample.txt
Output: 123456789

## User Story 2

Write a program that can validate a policy number using a checksum algorithm.

### Checksum Calculation
A valid policy number must satisfy the following checksum calculation:
```
(d1 + 2*d2 + 3*d3 + ... + 9*d9) mod 11 == 0
```
Where d1 is the rightmost digit and d9 is the leftmost digit of the policy number.

### Usage

```ruby
# Check if a policy number is valid
PolicyOcr::Validator.valid_checksum?('345882865')  # => true
PolicyOcr::Validator.valid_checksum?('111111111')  # => false

# Calculate the checksum value (0-10)
PolicyOcr::Validator.calculate_checksum('345882865')  # => 0 (valid)
PolicyOcr::Validator.calculate_checksum('111111111')  # => 1 (invalid)

# The Parser now includes validation in its output
parser = PolicyOcr::Parser.new('path/to/ocr_file.txt')
results = parser.parse
# => [
#      { number: '000000000', valid_checksum: true },
#      { number: '111111111', valid_checksum: false },
#      ...
#    ]
```

### Example:
```
Input: 345882865
Calculation: (5*1 + 6*2 + 8*3 + 2*4 + 8*5 + 8*6 + 5*7 + 4*8 + 3*9) % 11 = 0
Output: true
```

