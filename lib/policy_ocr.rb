module PolicyOcr
    class Parser
        def initialize(file_path = nil)
            @file_path = file_path || 'spec/fixtures/sample.txt'
        end

        def parse
            entries = []
            
            unless File.exist?(@file_path)
              raise ArgumentError, "File not found: #{@file_path}"
            end
            
            begin
              File.open(@file_path, 'r') do |file|
                file.each_line do |line|
                  entries << line.strip
                end
              end
              
              if entries.empty?
                raise StandardError, "File is empty: #{@file_path}"
              end
              
              entries
            rescue Errno::EACCES => e
              raise StandardError, "Permission denied when reading file: #{@file_path}"
            rescue => e
              raise StandardError, "Error reading file #{@file_path}: #{e.message}"
            end
        end
    end
end
