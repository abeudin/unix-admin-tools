#!/usr/bin/ruby

# author: Fabian Zeindl
# version: 1.0
# licence: GPL

require 'find'

def escape (filename)
  filename.gsub(/\\/,"\\\\\\\\")
  filename.gsub(/"/,"\\\"")
end

def unescape (filename)
  filename.gsub!(/\\\\/,"\\")
  filename.gsub!(/\\"/,"\"")
  filename.gsub!(/\\ /," ")
  filename.gsub!(/\\\[/,"[")
  filename.gsub!(/\\\]/,"]")
  filename.gsub!(/\\\(/,"(")
  filename.gsub!(/\\\)/,")")
  filename
end

root = ARGV[0]
min_mb = 500

files = Hash.new

find_command = "find #{root} -type f -size +#{min_mb}M"
find_list = `#{find_command}`
find_list.each {|filename|
  filename = filename[0..-2]
  inode = File.stat(filename).ino
  if files[inode].nil?
    files[inode] = {:links => [filename], :size => File.size?(filename)}
  else
    files[inode][:links] << filename
  end
}

if files.empty?
  puts "No files > #{min_mb}MB found."
  exit
end

# Dialog
text = "Welche Dateien sollen gelöscht werden?"

list = Array.new
files.sort{|b,a| a[1][:size] <=> b[1][:size]}.each{|file|
  info = file[1]
  size_in_mb = info[:size] / 1024 / 1024
  list << "\"#{escape(info[:links].first)}\"" << "\"#{size_in_mb} M\"" << "off"
} 

command = "dialog --stdout --checklist \"#{text}\" 0 0 0 #{list.join(" ")}"
result = `#{command}`
unless result.empty? 
  delfiles = result.split("\" \"")
  delfiles[0] = delfiles[0][1..-1]
  delfiles[-1] = delfiles[-1][0..-2]

  puts "Deleting files, and leaving .deleted_from_backup-notice"
  delfiles.each {|file|
    puts "  #{File.basename(unescape(file))}"
    inode = File.stat(unescape(file)).ino
    files[inode][:links].each {|link|
      del_command = "rm -f \"#{escape(link)}\""
      puts "    #{del_command}"
      system("touch \"#{escape(link)}\".deleted_from_backup")
      system(del_command)
    }
  }
end
