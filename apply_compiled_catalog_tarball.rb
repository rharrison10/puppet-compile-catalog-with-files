#!/usr/bin/ruby

nodefile = ARGV[0]
nodefile =~ /(.*)\.compiled_catalog_with_files.tar.gz/
nodename = $1

puts nodefile + " " + nodename

system("tar -xvPf #{nodefile}")

modulepath = File.open("#{nodename}.modulepath").readlines.first

system("puppet apply --debug --catalog #{nodename}.catalog.pson --modulepath '#{modulepath}'")
