#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('./lib')
#gems
require 'rspec'
require 'find'
require 'etc'
# libs
require 'determineos'
require 'messages'
require 'variables'
require 'cmd'

os_select = Determineos.new
os_decided = os_select.os.to_s
#workingdir = '.'
#apt_file_inst = "/usr/bin/apt-get install apt-file -y > /dev/null && /usr/bin/apt-file update > /dev/null"
#inputter = []
#Variables.fs_ext = ['pre', 'post', 'out']
#opt_sel = ['pre', 'post', 'final']
#opt_sel_err = "[-] Usage: ./rosetta.rb <package_name> <pre> | <post|final>"
#fs_footprint_fin = "Finished footprinting root filesystem. Results stored in " + fs_find_file
#fs_apt_file_txt = "Footprinting package contents..."

commands = []
ARGV.each {|arg| commands << arg}

#package_name = ARGV[0]
#fs_apt_file = "apt-file list " + package_name + " | grep -e share -v | cut -d ' ' -f2 > " + package_name+".package"
#fs_apt_file_txt_fin = "Finished footprinting " + package_name + ". Results stored in " +package_name+".package."
#rc_list_txt_fin = []
#output_file_rc = "startup."
#output_filetype_ary = "config_files."
#config_files_fin = []
group_list_txt_fin = []
#output_file_group = "group."
#group_list_txt = "Finished footprinting groups. Results stored in " + output_file_group
#group_list_txt_fp = "Footprinting groups..."
#user_list_txt_fin = []
#output_file_user = "user."
#user_list_txt = "Finished footprinting users. Results stored in " + output_file_user
#user_list_txt_fp = "Footprinting users..."
#net_stat = "/bin/netstat -tulpn > "
#net_stat_win = "netstat > "
#net_stat_txt = "Footprinting services..."
#output_file_net_stat = "services."
#net_stat_txt_fin = "Finished footprinting network ports. Results stored in " + output_file_net_stat
#apt_file_inst_chk = "/usr/bin/apt-get install chkconfig -y > /dev/null"
#chk_config = "chkconfig --list > "
#chk_config_txt = "Footprinting service startup state..."
#output_file_chk_config = "chkconfig."
#chk_config_txt_fin = "Finished footprinting service startup state. Results stored in " + output_file_chk_config

#name_files = ['chkconfig','filesystem','group','services','startup','user']
filetype_ary = []

#####################
# Debian and Ubuntu #
#####################
if os_decided == "nix" && File.exist?("/usr/bin/apt-get")
	puts Messages.deb

	if ARGV[1] == Variables.opt_sel[0]

		unless !File.exist?("/usr/bin/apt-file")
			puts Messages.apt_present
			system(Cmd.apt_file_inst)
		end
		unless File.exist?("/sbin/chkconfig")
			puts Messages.chkconfig_present
			system(Cmd.apt_file_inst_chk)
		end

		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home")))
   				inputter << path + "\n"
   			end
 		end
		File.open(Messages.fs_find_file+Variables.fs_ext[0], "w"){ |f| f.write(inputter)}
		puts Messages.fs_footprint_fin+Variables.fs_ext[0]+"."

		# Package contents
		puts ""
		puts Messages.fs_apt_file_txt
		system(Cmd.fs_apt_file)
		puts Messages.fs_apt_file_txt_fin

		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat+Messages.output_file_net_stat+Variables.fs_ext[0])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."

		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Etc.group {|g| Variables.group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		File.open(Messages.output_file_group+Variables.fs_ext[0], "w"){ |f| f.write(Variables.group_list_txt_fin)}
		puts Messages.group_list_txt+Variables.fs_ext[0]+"."

		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Etc.passwd {|u| Variables.user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		File.open(Messages.output_file_user+Variables.fs_ext[0], "w"){ |f| f.write(Variables.user_list_txt_fin)}
		puts Messages.user_list_txt+Variables.fs_ext[0]+"."

		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[0])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[0]+"."

		# Startup binaries
		puts ""
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc|
        Variables.rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(Messages.output_file_rc+Variables.fs_ext[0], "w"){ |f| f.write(Variables.rc_list_txt_fin)}

	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint
		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home")))
   				inputter << path + "\n"
      		end
 		end
		File.open(fs_find_file+Variables.fs_ext[1], "w"){ |f| f.write(inputter)}
		puts Messages.fs_footprint_fin+Variables.fs_ext[1]+"."

		# Package contents not required for post-install footprinting
		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat+Messages.output_file_net_stat+Variables.fs_ext[1])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[1]+"."

		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Etc.group {|g| Variables.group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		File.open(Messages.output_file_group+Variables.fs_ext[1], "w"){ |f| f.write(Variables.group_list_txt_fin)}
		puts Messages.group_list_txt+Variables.fs_ext[1]+"."

		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Etc.passwd {|u| Variables.user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		File.open(Messages.output_file_user+Variables.fs_ext[1], "w"){ |f| f.write(Variables.user_list_txt_fin)}
		puts Messages.user_list_txt+Variables.fs_ext[1]+"."

		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[1])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[1]+"."

		# Startup binaries
		puts ""
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc| Variables.rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(Messages.output_file_rc+Variables.fs_ext[1], "w"){ |f| f.write(Variables.rc_list_txt_fin)}

	else ARGV[1] == Variables.opt_sel[2]
		puts Messages.post_a_compare
		Variables.name_files.each do |naming|
			f1 = IO.readlines(workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
		end
		
		puts Messages.prob_config

		IO.readlines(workingdir + "/filesystem.out").map(&:chomp).each do |filetype|
			if filetype =~ /\.conf/
				filetype_ary << filetype
			elsif filetype =~ /\.properties/
				filetype_ary << filetype
			elsif filetype =~ /\.config/
				filetype_ary << filetype
			elsif filetype =~ /\.xml/
				filetype_ary << filetype
			elsif filetype =~ /\.json/
				filetype_ary << filetype
			end
		File.open(Messages.output_filetype_ary+Variables.fs_ext[1], "w"){ |f| f.write((filetype_ary).join("\n"))}
		end
		puts Messages.post_analysis
	end


######################
# Red Hat and CentOS #
######################
elsif os_decided == "nix" && File.exist?(Variables.package_rh)
	if ARGV[1] == Variables.opt_sel[0]
		puts Messages.rh
		
		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		#Cmd.fs_open
		#Cmd.exclude_and_write
		#Cmd.close_file
		f = File.open(Messages.fs_find_file+Variables.fs_ext[0], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.fs_footprint_fin+Variables.fs_ext[0]+"."
		
		# Network services <- *********  WORKING
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat+Messages.output_file_net_stat+Variables.fs_ext[0])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."
		
		# Group information <- ****** WORKING
		puts ""
		puts Messages.group_list_txt_fp
		Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		grp = File.open(Messages.output_file_group+Variables.fs_ext[0], "w")
		group_list_txt_fin.each {|grp_list| grp.write(grp_list)}
		grp.close()
		puts Messages.group_list_txt+Variables.fs_ext[0]+"."
		
		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		usr = File.open(Messages.output_file_user+Variables.fs_ext[0], "w")
		user_list_txt_fin.each { |usr_list| usr.write(usr_list)}
		puts Messages.user_list_txt+Variables.fs_ext[0]+"."
		
		# CHKCONFIG Information <- ******** WORKING
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[0])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[0]+"."
		
		# Startup binaries
		puts ""
		Dir.glob("/etc/rc?.d").each { |rc_list| Find.find(rc_list) { |pathrc| Variables.rc_list_txt_fin << pathrc + "\n"}}
		File.open(Messages.output_file_rc+Variables.fs_ext[0], "w"){ |f| f.write(Variables.rc_list_txt_fin)}
	
	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint
		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		Find.find('/') do |path|
 			if (! ((path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home")))
   				inputter << path + "\n"
   			end
 		end
		File.open(Messages.fs_find_file+Variables.fs_ext[1], "w"){ |f| f.write(inputter)}
		puts Messages.fs_footprint_fin+Variables.fs_ext[1]+"."
		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat+Messages.output_file_net_stat+Variables.fs_ext[1])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[1]+"."
		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		Etc.group {|g| Variables.group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
		File.open(Messages.output_file_group+Variables.fs_ext[1], "w"){ |f| f.write(Variables.group_list_txt_fin)}
		puts Messages.group_list_txt+Variables.fs_ext[1]+"."
		# User information
		puts ""
		puts Messages.user_list_txt_fp
		Etc.passwd {|u| Variables.user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
		File.open(Messages.output_file_user+Variables.fs_ext[1], "w"){ |f| f.write(Variables.user_list_txt_fin)}
		puts Messages.user_list_txt+Variables.fs_ext[1]+"."
		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[1])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[1]+"."
		# Startup binaries
		puts ""
		Dir.glob("/etc/rc?.d").each do |rc_list|
			Find.find(rc_list) do |pathrc| Variables.rc_list_txt_fin << pathrc + "\n"
			end
		end
		File.open(Messages.output_file_rc+Variables.fs_ext[1], "w"){ |f| f.write(Variables.rc_list_txt_fin)}

	else ARGV[1] == Variables.opt_sel[2]
		puts Messages.post_a_compare
		Variables.name_files.each do |naming|
			f1 = IO.readlines(workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
		end

		puts Messages.prob_config

		IO.readlines(workingdir + "/filesystem.out").map(&:chomp).each do |filetype|
			if filetype =~ /\.conf/
				filetype_ary << filetype
			elsif filetype =~ /\.properties/
				filetype_ary << filetype
			elsif filetype =~ /\.config/
				filetype_ary << filetype
			elsif filetype =~ /\.xml/
				filetype_ary << filetype
			elsif filetype =~ /\.json/
				filetype_ary << filetype
			end
		File.open(Messages.output_filetype_ary+Variables.fs_ext[1], "w"){ |f| f.write((filetype_ary).join("\n"))}
		end
		puts Messages.post_analysis
	end
	

#####################
# Microsoft Windows #
#####################
elsif os_decided == "windows"
	if ARGV[1] == Variables.opt_sel[0]
		puts Messages.ms

		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		Find.find('/') do |path|
   			inputter << path + "\n"
 		end
		File.open(Messages.fs_find_file+Variables.fs_ext[0], "w"){ |f| f.write(inputter)}
		puts Messages.fs_footprint_fin+Variables.fs_ext[0]+"."

		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat_win+Messages.output_file_net_stat+Variables.fs_ext[0])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."

		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		system(wmic GROUP > group.pre)
		puts Messages.group_list_txt+Variables.fs_ext[0]+"."

 		# User information
		puts ""
		puts Messages.user_list_txt_fp
		system(wmic USERACCOUNT LIST FULL > user.pre)
		puts Messages.user_list_txt+Variables.fs_ext[0]+"."

		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(wmic SERVICE LIST FULL > services.pre)
		puts Messages.chk_config_txt_fin+Variables.fs_ext[0]+"."

=begin		
		# Windows Registry
		Win32::Registry::HKEY_CURRENT_USER.open('SOFTWARE') do |reg|
		reg.each_value do |name, type, data|        # Enumerate values
	    reg.each_key { |key, wtime| ... }                # Enumerate subkeys
=end

	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint

		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		Find.find('/') do |path|
   			inputter << path + "\n"
   		end
		File.open(Messages.fs_find_file+Variables.fs_ext[1], "w"){ |f| f.write(inputter)}
		puts Messages.fs_footprint_fin+Variables.fs_ext[1]+"."

		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat_win+Messages.output_file_net_stat+Variables.fs_ext[1])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[1]+"."

		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		system(wmic GROUP > group.post)
		puts Messages.group_list_txt+Variables.fs_ext[1]+"."

		# User information
		puts ""
		puts Messages.user_list_txt_fp
		system(wmic USERACCOUNT LIST FULL > user.pre)
		puts Messages.user_list_txt+Variables.fs_ext[1]+"."

		# CHKCONFIG Information
		puts ""
		puts Messages.chk_config_txt
		system(Cmd.chk_config+Messages.output_file_chk_config+Variables.fs_ext[1])
		puts Messages.chk_config_txt_fin+Variables.fs_ext[1]+"."
		
		#Windows Registry

	else ARGV[1] == Variables.opt_sel[2]
		puts Messages.post_a_compare
		Variables.name_files.each do |naming|
			f1 = IO.readlines(workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
		end
		puts Messages.post_analysis
	end

#
# Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\') do |reg|
# reg.each_value { |name, type, data| ... }        # Enumerate values
# reg.each_key { |key, wtime| ... }                # Enumerate subkeys
# end
else
  puts Messages.opt_sel_err
end