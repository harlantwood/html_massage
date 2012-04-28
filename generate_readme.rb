#!/usr/bin/env ruby

class IO
  def self.write( path, content )
    file = File.new( path, "w" )
    file.write( content )
    file.close
  end
end

CHUNK_SEP = "\n\n"

def is_code?( markdown )
  markdown.start_with?( '    ' )
end

def header( text, top_newlines )
  puts "\n" * top_newlines
  puts '*'*10
  puts text
  puts '*'*10
end

system( "cp README.md README-backup-#{Time.now.to_s.gsub(/\W/, '-')}.md" )
readme = IO.read( 'README.md' )
chunks = readme.split( CHUNK_SEP )
code = ''
new_readme = ''
chunks.each do |chunk|
  if is_code?( chunk )

    chunk
    code << chunk << CHUNK_SEP

    header( 'Code', 3 )
    puts code
    header( 'Result', 1 )
    puts result = eval( code )

    unless result.nil?
      p 111, chunk
      result = result.to_s
      _, code_sans_results = chunk.match( /\A((?:    [^#].*\r?\n)+)(?:    #.*\r?\n)+\Z/ ).to_a
      if code_sans_results
        p 222
        result = result.split("\n").map{ |line| "    # #{line}" }.join("\n")
        chunk = code_sans_results << result << CHUNK_SEP
      end
    end

    header( 'Output', 1 )
    puts chunk

    new_readme << chunk << CHUNK_SEP
  end

end

IO.write( 'README.md', new_readme )
