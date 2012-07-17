#!/usr/bin/ruby

nodefile = ARGV[0]
nodefile =~ /(.*)\.compiled_catalog_with_files/
nodename = $1

system('tar -xvPf #{nodefile}')

modulepath = File.open("#{nodename}.modulepath").readlines.first

system("puppet apply --debug --apply #{nodename}.catalog.pson --modulepath '#{modulepath}'")
