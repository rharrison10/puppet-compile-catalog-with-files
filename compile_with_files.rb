#!/usr/bin/env ruby
require 'getoptlong'
require 'puppet'

opts = GetoptLong.new(
  [ '--node',           '-n', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--confdir',        '-c', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--manifest',       '-m', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--modulepath',     '-p', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--vardir',         '-v', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--external_nodes', '-e', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--debug',          '-d', GetoptLong::OPTIONAL_ARGUMENT ]
)

# Set some defaults
node, external_nodes, debug = 'default', nil, false
confdir, manifest, modulepath, vardir = nil

opts.each do |opt, arg|
  case opt
    when '--node'
      node = arg
    when '--confdir'
      confdir = arg
    when '--manifest'
      manifest = arg
    when '--modulepath'
      modulepath = arg
    when '--external_nodes'
      external_nodes = arg
    when '--vardir'
      vardir = arg
    when '--debug'
      debug = true
  end
end

if confdir
  Puppet[:confdir] = confdir
end

Puppet.initialize_settings_for_run_mode(:master)

if manifest
  Puppet[:manifest] = manifest
end

if modulepath
  Puppet[:modulepath] = modulepath
end

if vardir
  Puppet[:vardir] = vardir
end

# tell puppet to get facts from yaml
# Puppet::Node::Facts.terminus_class = :yaml

if external_nodes
  # use the external nodes tool - should read from puppet's puppet.conf
  # but doesn't read from the master section because run_mode can't be set.  ticket #4790
  Puppet[:node_terminus] = :exec
  Puppet[:external_nodes] = external_nodes
end

# we're running this on the server but Puppet.run_mode doesn't know that in this script
# so it ends up using clientyamldir
Puppet[:clientyamldir] = Puppet[:yamldir]
begin
  unless compiled_catalog = Puppet::Resource::Catalog.indirection.find(node)
    raise "Could not compile catalog for #{node}"
  end
  compiled_catalog_pson_string = compiled_catalog.to_pson

  paths = compiled_catalog.vertices.
      select {|vertex| vertex.type == "File" and vertex[:source] =~ %r{puppet://}}.
      map do |file_resource|
        file_metadata = Puppet::FileServing::Metadata.indirection.find(file_resource[:source])
        puts "The file #{file_resource[:source]} is not accessible" if file_metadata.nil?
        file_metadata
      end.
      compact.
      map {|filemetadata| filemetadata.path}.
      uniq

rescue => detail
  $stderr.puts detail
  exit(30)
end

if debug
  require 'pp'

  puts "Outputting the files to include in the tarball\n\n"
  pp paths

  puts "Outputting the compiled catalog\n\n"
  puts compiled_catalog_pson_string
end

catalog_file = File.new("#{node}.catalog.pson", "w")
catalog_file.write compiled_catalog_pson_string
catalog_file.close

File.open("#{node}.modulepath", 'w') {|f| f.write(Puppet[:modulepath])}

tarred_filename = "#{node}.compiled_catalog_with_files.tar.gz"
`tar -cPzf #{tarred_filename} #{catalog_file.path} #{node}.modulepath #{paths.join(' ')}`
puts "Created #{tarred_filename} with the compiled catalog for node #{node} and the necessary files"

File.delete(catalog_file.path)
File.delete("#{node}.modulepath")
