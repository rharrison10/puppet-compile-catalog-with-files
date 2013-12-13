#!/usr/bin/ruby

nodefile = ARGV[0]
nodefile =~ /(.*)\.compiled_catalog_with_files.tar.gz/
nodename = $1

system("tar -xvPf #{nodefile}")

modulepath = File.open("#{nodename}.modulepath").readlines.first

system("puppet apply --detailed-exitcodes --verbose --write-catalog-summary --catalog #{nodename}.catalog.pson --modulepath '#{modulepath}'")

# Clean up the files down loaded to the file system.
# Get the list of files from the tarball
nodefile_files = `tar tzvf backup1.test.rhcloud.com.compiled_catalog_with_files.tar.gz`.split(/\n/).map { |line| line.split[5] }

# Sorting and reversing the array means we'll operate on any directories after
# their files have already been removed.
nodefile_files.sort.reverse.each do | file_name |
  File.delete(file_name) if File.file?(file_name)
  Dir.delete(file_name) if File.directory?(file_name)
end
