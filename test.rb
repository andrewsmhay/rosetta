#!/usr/bin/env ruby
workingdir = '/home/ubuntu/rosetta'
fs_ext = 'out'
post_files = ['chkconfig.post','filesystem.post','group.post','services.post','startup.post','user.post']
pre_files = ['chkconfig.pre','filesystem.pre','group.pre','services.pre','startup.pre','user.pre'] 
	
puts "[+] Initalizing post-analysis comparisons..."

post_files_chkconfig = IO.readlines(workingdir + "/chkconfig.post").map(&:chomp)
pre_files_chkconfig = IO.readlines(workingdir + "/chkconfig.post").map(&:chomp)

puts ""
puts "post_files_chkconfig"
p post_files_chkconfig 
puts ""
puts "pre_files_chkconfig"
p pre_files_chkconfig
puts ""

File.open(workingdir + "/chkconfig.out", "w"){ |f| f.write((post_files_chkconfig-pre_files_chkconfig).join("\n")) }

puts ""
puts "[+] Post-analysis comparisons completed."
