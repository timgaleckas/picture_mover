#!/usr/bin/env ruby

require 'rubygems'
require 'mini_exiftool'
require 'fileutils'

IMPORT_METHOD = :mv
RM_ON_IDENTICAL = true
NUMBER_REGEX = /_([0-9])$/
VIDEO_EXTS = %w(3gp m4v mp4 mov avi mpg)
PICTURE_EXTS = %W(jpg png jpeg gif)

def md5sum(file)
  md5 = `md5sum '#{file}' | cut -d ' ' -f 1`.chomp
  raise 'whoops' unless md5.size == 32
  md5
end

def safe_copy(source_file, dest_file)
  if File.exists?(dest_file)
    if File.size(dest_file)==File.size(source_file) && md5sum(dest_file)==md5sum(source_file)
      puts "#{source_file} already exists in #{dest_file} and is identical"
      if RM_ON_IDENTICAL
        puts "Removing #{source_file}"
        FileUtils.rm(source_file)
      end
    else
      puts "#{source_file} already exists in #{dest_file} but is different"
      extention = dest_file[dest_file.rindex('.'),dest_file.size]
      stripped_dest_file = dest_file[0...dest_file.rindex('.')]

      new_dest_file = if match_data = stripped_dest_file.match(NUMBER_REGEX)
                        stripped_dest_file.gsub(NUMBER_REGEX,"_#{match_data[1].to_i+1}") + extention
                      else
                        stripped_dest_file + "_1" + extention
                      end

      safe_copy(source_file, new_dest_file)
    end
  else
    puts "#{IMPORT_METHOD}ing #{source_file} to #{dest_file}"
    FileUtils.send(IMPORT_METHOD, source_file, dest_file)
  end
end

exts = PICTURE_EXTS + VIDEO_EXTS
glob = "#{ARGV[0]}/**/*.{#{exts.join(",")}}"

Dir.glob(glob).each do |source_file|
  begin
    exif = MiniExiftool.new(source_file)
    date_time = exif.create_date || File.mtime(source_file)
    date_directory_name = case File.extname(source_file.downcase)[1..-1]
                          when *VIDEO_EXTS
                            date_time.strftime('Videos/%Y/%Y_%m_%d')
                          when *PICTURE_EXTS
                            date_time.strftime('Pictures/%Y/%Y_%m_%d')
                          else
                            raise "Dunno how to deal with #{source_file[-3..-1]}"
                          end
    FileUtils.mkdir_p(date_directory_name) unless File.directory?(date_directory_name)
    dest_file = "#{date_directory_name}/#{File.basename(source_file)}"
    safe_copy(source_file,dest_file)
  rescue StandardError => e
    puts e.inspect
  end
end
