#!/usr/bin/env ruby

require './lib/determineos.rb'
require 'find'

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

if os_decided == "nix" && File.exist?("/usr/bin/apt-get")
	prints "This is a Debian / Ubuntu distro using the apt package manager."
	if ARGV[1] == '--phase pre'
		# apt-get install apt-file -y && apt-file update
		if File.exist?("/usr/bin/apt-file")
		else
			prints "The apt-file program is not installed...installing now."
			system(apt_file_inst)
		end
		prints fs_footprint
		# find / | egrep -e '/proc/' -v | egrep -e '/dev/' -v > filesystem.pre
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/")))
   				inputter << path + "\n"
 			end
		prints fs_footprint_fin+fs_ext[0]
		File.open(fs_find_file+fs_ext[0], "w"){ |f| f.write(inputter)}
		# apt-file list <package>
		prints fs_apt_file_txt
		system(fs_apt_file)
		prints fs_apt_file_txt_fin
		# netstat -tulpn > services.pre
		# cut -d ":" -f1 /etc/shadow > users.pre
		# cut -d ":" -f1,4 /etc/group > groups.pre
		# chkconfig --list > chkconfig.pre
		# find /etc/rc*.d/S* -executable && find /etc/init.d/ -not -path "/etc/init.d/" > startup.pre
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc|	
			rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(output_file_rc+ARGV[0], "w"){ |f| f.write(rc_list_txt_fin)}




		
	elsif ARGV[1] == '--phase post'
		prints "Initalizing post-installation footprinting..."
		if File.exist?("/usr/bin/apt-file")
		else
			prints "The apt-file program is not installed...installing now."
			system(apt_file_inst)
		end
		prints fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/")))
   				inputter << path + "\n"
 			end
		prints fs_footprint_fin+fs_ext[1]
		File.open(fs_find_file+fs_ext[1], "w"){ |f| f.write(inputter)}
		
	elsif ARGV[1] == '--phase final'
		prints "Initalizing post-analysis comparisons..."
	else prints "Please try again..."

elsif os_decided == "nix" && File.exist?("/usr/bin/yum")
	prints "This is a Red Hat / CentOS based distro using the yum package manager."
elsif os_decided == "nix" && File.exist?("/usr/bin/rpm")
	prints "This is a Red Hat / CentOS based distro using the rpm package manager."
elsif os_decided == "windows"
	prints "This is a Windows based distro."
else print "The OS could not be detected or is not supported. Goodbye."

end









