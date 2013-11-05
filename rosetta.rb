#!/usr/bin/env ruby
require './lib/determineos.rb'
require 'find'
require 'etc'

os_select = Determineos.new
os_decided = os_select.os.to_s
workingdir = '.'
fs_footprint = "Footprinting root filesystem..."
fs_find_file = "filesystem."
apt_file_inst = "/usr/bin/apt-get install apt-file -y > /dev/null && /usr/bin/apt-file update > /dev/null"
inputter = []
fs_ext = ['pre', 'post', 'out']
opt_sel = ['pre', 'post', 'final']
opt_sel_err = "[-] Usage: ./rosetta.rb <package_name <pre> | <post|final>"
fs_footprint_fin = "Finished footprinting root filesystem. Results stored in " + fs_find_file
fs_apt_file_txt = "Footprinting package contents..."

commands = []
ARGV.each {|arg| commands << arg}

package_name = ARGV[0]
fs_apt_file = "apt-file list " + package_name + " | grep -e share -v | cut -d ' ' -f2 > " + package_name+".package"
fs_apt_file_txt_fin = "Finished footprinting " + package_name + ". Results stored in " +package_name+".package."
rc_list_txt_fin = []
output_file_rc = "startup."
group_list_txt_fin = []
output_file_group = "group."
group_list_txt = "Finished footprinting groups. Results stored in " + output_file_group
group_list_txt_fp = "Footprinting groups..."
user_list_txt_fin = []
output_file_user = "user."
user_list_txt = "Finished footprinting users. Results stored in " + output_file_user
user_list_txt_fp = "Footprinting users..."
net_stat = "/bin/netstat -tulpn > "
net_stat_txt = "Footprinting services..."
output_file_net_stat = "services."
net_stat_txt_fin = "Finished footprinting network ports. Results stored in " + output_file_net_stat
apt_file_inst_chk = "/usr/bin/apt-get install chkconfig -y > /dev/null"
chk_config = "chkconfig --list > "
chk_config_txt = "Footprinting service startup state..."
output_file_chk_config = "chkconfig."
chk_config_txt_fin = "Finished footprinting service startup state. Results stored in " + output_file_chk_config

name_files = ['chkconfig','filesystem','group','services','startup','user']


#####################
# Debian and Ubuntu #
#####################
if os_decided == "nix" && File.exist?("/usr/bin/apt-get")
	puts "This is a Debian / Ubuntu distro using the apt package manager."
	if ARGV[1] == opt_sel[0]
		if File.exist?("/usr/bin/apt-file")
		else
			puts "The 'apt-file' program is not installed...installing now."
			system(apt_file_inst)
		end
		if File.exist?("/sbin/chkconfig")
		else
			puts "The 'chkconfig' program is not installed...installing now."
			system(apt_file_inst_chk)
		end
		# Filesystem footprinting
		puts ""
		puts fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum")))
   				inputter << path + "\n"
   			end
 		end
		File.open(fs_find_file+fs_ext[0], "w"){ |f| f.write(inputter)}
		puts fs_footprint_fin+fs_ext[0]+"."
		# Package contents
		puts ""
		puts fs_apt_file_txt
		system(fs_apt_file)
		puts fs_apt_file_txt_fin
		# Network services
		puts ""
		puts net_stat_txt
		system(net_stat+output_file_net_stat+fs_ext[0])
		puts net_stat_txt_fin+fs_ext[0]+"."
		# Group information
		puts ""
		puts group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		File.open(output_file_group+fs_ext[0], "w"){ |f| f.write(group_list_txt_fin)}
		puts group_list_txt+fs_ext[0]+"."
		# User information
		puts ""
		puts user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		File.open(output_file_user+fs_ext[0], "w"){ |f| f.write(user_list_txt_fin)}
		puts user_list_txt+fs_ext[0]+"."
		# CHKCONFIG Information
		puts ""
		puts chk_config_txt
		system(chk_config+output_file_chk_config+fs_ext[0])
		puts chk_config_txt_fin+fs_ext[0]+"."
		# Startup binaries
		puts ""
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc| rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(output_file_rc+fs_ext[0], "w"){ |f| f.write(rc_list_txt_fin)}
	
	elsif ARGV[1] == opt_sel[1]
		puts "Initalizing post-installation footprinting..."
		# Filesystem footprinting
		puts ""
		puts fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum")))
   				inputter << path + "\n"
   			end
 		end
		File.open(fs_find_file+fs_ext[1], "w"){ |f| f.write(inputter)}
		puts fs_footprint_fin+fs_ext[1]+"."
		# Package contents not required for post-install footprinting
		# Network services
		puts ""
		puts net_stat_txt
		system(net_stat+output_file_net_stat+fs_ext[1])
		puts net_stat_txt_fin+fs_ext[1]+"."
		# Group information
		puts ""
		puts group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		File.open(output_file_group+fs_ext[1], "w"){ |f| f.write(group_list_txt_fin)}
		puts group_list_txt+fs_ext[1]+"."
		# User information
		puts ""
		puts user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		File.open(output_file_user+fs_ext[1], "w"){ |f| f.write(user_list_txt_fin)}
		puts user_list_txt+fs_ext[1]+"."
		# CHKCONFIG Information
		puts ""
		puts chk_config_txt
		system(chk_config+output_file_chk_config+fs_ext[1])
		puts chk_config_txt_fin+fs_ext[1]+"."
		# Startup binaries
		puts ""
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc| rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(output_file_rc+fs_ext[1], "w"){ |f| f.write(rc_list_txt_fin)}

	else ARGV[1] == opt_sel[2]
		puts "Initalizing post-analysis comparisons..."
		name_files.each do |naming|
			f1 = IO.readlines(workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
		end
		puts "Post-analysis comparisons completed."
	end


######################
# Red Hat and CentOS #
######################
elsif os_decided == "nix" && File.exist?("/usr/bin/yum")
	if ARGV[1] == opt_sel[0]
		puts "This is a Red Hat / CentOS based distro using the yum package manager."
		# Filesystem footprinting
		puts ""
		puts fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum")))
   				inputter << path + "\n"
   			end
 		end
		File.open(fs_find_file+fs_ext[0], "w"){ |f| f.write(inputter)}
		puts fs_footprint_fin+fs_ext[0]+"."
		# Network services
		puts ""
		puts net_stat_txt
		system(net_stat+output_file_net_stat+fs_ext[0])
		puts net_stat_txt_fin+fs_ext[0]+"."
		# Group information
		puts ""
		puts group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		File.open(output_file_group+fs_ext[0], "w"){ |f| f.write(group_list_txt_fin)}
		puts group_list_txt+fs_ext[0]+"."
		# User information
		puts ""
		puts user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		File.open(output_file_user+fs_ext[0], "w"){ |f| f.write(user_list_txt_fin)}
		puts user_list_txt+fs_ext[0]+"."
		# CHKCONFIG Information
		puts ""
		puts chk_config_txt
		system(chk_config+output_file_chk_config+fs_ext[0])
		puts chk_config_txt_fin+fs_ext[0]+"."
		# Startup binaries
		puts ""
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc| rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(output_file_rc+fs_ext[0], "w"){ |f| f.write(rc_list_txt_fin)}
	
	elsif ARGV[1] == opt_sel[1]
		puts "Initalizing post-installation footprinting..."
		# Filesystem footprinting
		puts ""
		puts fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum")))
   				inputter << path + "\n"
   			end
 		end
		File.open(fs_find_file+fs_ext[1], "w"){ |f| f.write(inputter)}
		puts fs_footprint_fin+fs_ext[1]+"."
		# Network services
		puts ""
		puts net_stat_txt
		system(net_stat+output_file_net_stat+fs_ext[1])
		puts net_stat_txt_fin+fs_ext[1]+"."
		# Group information
		puts ""
		puts group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		File.open(output_file_group+fs_ext[1], "w"){ |f| f.write(group_list_txt_fin)}
		puts group_list_txt+fs_ext[1]+"."
		# User information
		puts ""
		puts user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		File.open(output_file_user+fs_ext[1], "w"){ |f| f.write(user_list_txt_fin)}
		puts user_list_txt+fs_ext[1]+"."
		# CHKCONFIG Information
		puts ""
		puts chk_config_txt
		system(chk_config+output_file_chk_config+fs_ext[1])
		puts chk_config_txt_fin+fs_ext[1]+"."
		# Startup binaries
		puts ""
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc| rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(output_file_rc+fs_ext[1], "w"){ |f| f.write(rc_list_txt_fin)}

	else ARGV[1] == opt_sel[2]
		puts "Initalizing post-analysis comparisons..."
		name_files.each do |naming|
			f1 = IO.readlines(workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
		end
		puts "Post-analysis comparisons completed."
	end
	

#####################
# Microsoft Windows #
#####################
#elsif os_decided == "windows"
#	puts "This is a Windows based distro."
#   Filesystem footprinting
#	puts ""
#	puts fs_footprint
#	Find.find('/') do |path|
# 			inputter << path + "\n"
#		end
#	File.open(fs_find_file+fs_ext[0], "w"){ |f| f.write(inputter)}
#	puts fs_footprint_fin+fs_ext[0]+"."
#
# Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\') do |reg|
# reg.each_value { |name, type, data| ... }        # Enumerate values
# reg.each_key { |key, wtime| ... }                # Enumerate subkeys
# end
else puts opt_sel_err
end