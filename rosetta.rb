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
fs_footprint_fin = "Finished footprinting root filesystem. Results stored in " + fs_find_file
fs_apt_file_txt = "Footprinting package contents..."

if ARGV.size != 1 then
  puts "n[-] Usage: ./rosetta.rb <package name> --phase <pre|post|final>"
  exit
end

package_name = ARGV[0]
fs_apt_file = "apt-file list " + package_name + " | grep -e share -v | cut -d " " -f2 > " + package_name+"package"
fs_apt_file_txt_fin = "Finished footprinting " + package_name + ". Results stored in " +package_name+"package."
rc_list_txt_fin = []
output_file_rc = "startup."
group_list_txt_fin = []
output_file_group = "group."
group_list_txt = "Finished footprinting groups. Results stored in " + output_file_group
user_list_txt_fin = []
output_file_user = "user."
user_list_txt = "Finished footprinting users. Results stored in " + output_file_user
net_stat = "/bin/netstat -tulpn > "
net_stat_txt = "Footprinting services..."
output_file_net_stat = "services."
net_stat_txt_fin = "Finished footprinting network ports. Results stored in " + output_file_net_stat
apt_file_inst_chk = "/usr/bin/apt-get install chkconfig -y > /dev/null"
chk_config = "chkconfig --list >"
chk_config_txt = "Footprinting service startup state..."
output_file_chk_config = "chkconfig."
chk_config_txt_fin = "Finished footprinting service startup state. Results stored in " + output_file_chk_config

if os_decided == "nix" && File.exist?("/usr/bin/apt-get")
	puts "This is a Debian / Ubuntu distro using the apt package manager."
	if ARGV[1] == '--phase pre'
		# apt-get install apt-file -y && apt-file update
		if File.exist?("/usr/bin/apt-file")
			puts "The 'apt-file' program is already installed. Continuing..."
		else
			puts "The 'apt-file' program is not installed...installing now."
			system(apt_file_inst)
		end
		if File.exist?("/sbin/chkconfig")
			puts "The 'chkconfig' program is already installed. Continuing..."
		else
			puts "The 'chkconfig' program is not installed...installing now."
			system(apt_file_inst_chk)
		end
		
		# find / | egrep -e '/proc/' -v | egrep -e '/dev/' -v > filesystem.pre
		puts fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/")))
   				inputter << path + "\n"
 			end
		puts fs_footprint_fin+fs_ext[0]
		File.open(fs_find_file+fs_ext[0], "w"){ |f| f.write(inputter)}
		
		# apt-file list <package>
		puts fs_apt_file_txt
		system(fs_apt_file)
		puts fs_apt_file_txt_fin+fs_ext[0]
		
		# netstat -tulpn > services.pre
		puts net_stat_txt
		system(net_stat+output_file_net_stat)
		puts net_stat_txt_fin+fs_ext[0]

		# cut -d ":" -f1,4 /etc/group > groups.pre
		puts group_list_txt
		Etc.group {|g|
  			group_list_txt_fin << g.name + ": " + g.mem.join(', ')
		}
		File.open(output_file_group+fs_ext[0], "w"){ |f| f.write(group_list_txt_fin)}
		
		# cut -d ":" -f1 /etc/shadow > users.pre
		puts user_list_txt+fs_ext[0]
		Etc.passwd {|u|
			user_list_txt_fin << u.name + " = " + u.gecos
		}
		File.open(output_file_user+fs_ext[0], "w"){ |f| f.write(user_list_txt_fin)}
		puts user_list_txt+fs_ext[0]
		
		# chkconfig --list > chkconfig.pre
		puts chk_config_txt
		system(chk_config+output_file_chk_config)
		puts chk_config_txt_fin+fs_ext[0]
		
		# find /etc/rc*.d/S* -executable && find /etc/init.d/ -not -path "/etc/init.d/" > startup.pre
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc|	
			rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(output_file_rc+fs_ext[0], "w"){ |f| f.write(rc_list_txt_fin)}
	end




		
#	elsif ARGV[1] == '--phase post'
#		puts "Initalizing post-installation footprinting..."
#		if File.exist?("/usr/bin/apt-file")
#		else
#			puts "The apt-file program is not installed...installing now."
#			system(apt_file_inst)
#		end
#		puts fs_footprint
#		Find.find('/') do |path|
# 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/")))
#   				inputter << path + "\n"
# 			end
#		puts fs_footprint_fin+fs_ext[1]
#		File.open(fs_find_file+fs_ext[1], "w"){ |f| f.write(inputter)}
#		
#	elsif ARGV[1] == '--phase final'
#		puts "Initalizing post-analysis comparisons..."
#	else puts "Please try again..."
#
#elsif os_decided == "nix" && File.exist?("/usr/bin/yum")
#	puts "This is a Red Hat / CentOS based distro using the yum package manager."
#elsif os_decided == "nix" && File.exist?("/usr/bin/rpm")
#	puts "This is a Red Hat / CentOS based distro using the rpm package manager."
#elsif os_decided == "windows"
#	puts "This is a Windows based distro."
else print "The OS could not be detected or is not supported. Goodbye."

end