#!/usr/bin/env ruby
#workingdir = '/home/ubuntu/rosetta'
=begin workingdir = '/Users/ahay/Documents/Research/Development/rosetta'
fs_ext = 'out'
post_files = ['chkconfig.post','filesystem.post','group.post','services.post','startup.post','user.post']
pre_files = ['chkconfig.pre','filesystem.pre','group.pre','services.pre','startup.pre','user.pre'] 
	
puts "[+] Initalizing post-analysis comparisons..."

f1 = IO.readlines(workingdir + "/chkconfig.pre").map(&:chomp)
f2 = IO.readlines(workingdir + "/chkconfig.post").map(&:chomp)

puts f2 - f1

File.open(workingdir + "/chkconfig.out", "w"){ |f| f.write((f2 - f1).join("\n")) }

puts ""
puts "[+] Post-analysis comparisons completed."
=end

Win32::Registry::HKEY_CURRENT_USER.open('SOFTWARE') do |reg|
	reg.each_value do |name, type, data| 
		puts name
		puts type
		puts data
	end
	#reg.each_key { |key, wtime| ... }                # Enumerate subkeys
end