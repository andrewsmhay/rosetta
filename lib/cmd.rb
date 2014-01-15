require 'messages'

class Cmd
	class << self

		@@nixPathExclude = "^(\\.|\\/dev|\\/proc|\\/sys|\\/root|\\/user\\/share\\/doc|\\/var\\/lib\\/yum|\\/home).*$"
		@@winPathExclude = "^(\\.|\\/\\$Recycle\\.Bin).*$"

		def fs_footprint(fs_ext = "", os="")
			if os === "" || fs_ext === ""
				puts "Invalid call to fs_footprint. Exiting"
				exit -1
			end

			exclude = ""

			puts ""
			puts Messages.fs_footprint
			
			case os
			when "windows"
				exclude = @@winPathExclude
			else
				exclude = @@nixPathExclude
			end

			f = File.open(Messages.fs_find_file+fs_ext, "w")
			Find.find('/'){|path| f.write(path + "\n") unless path =~ /#{exclude}/}
			f.close()

			puts Messages.fs_footprint_fin+fs_ext+"."
		end

		def netstat(fs_ext = "", os="")
			if os === "" || fs_ext === ""
				puts "Invalid call to netstat. Exiting."
				exit -1
			end

			netstatCmdStr = ""

			puts ""
			puts Messages.net_stat_txt

			case os
			when "windows"
				netstatCmdStr = net_stat_win
			else
				netstatCmdStr = net_stat_nix
			end

			system(netstatCmdStr+Messages.output_file_net_stat+fs_ext)
			puts Messages.net_stat_txt_fin+fs_ext+"."
		end

		def listGroups(fs_ext = "", os="")
			if os === "" || fs_ext === ""
				puts "Invalid call to netstat. Exiting."
				exit -1
			end

			group_list_txt_fin = []

			puts ""
			puts Messages.group_list_txt_fp

			case os
			when "windows"
				system(wmic_grp + Messages.output_file_group + fs_ext)
			else
				Etc.group {|g| group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
				grp = File.open(Messages.output_file_group+fs_ext, "w")
				group_list_txt_fin.each {|grp_list| grp.write(grp_list)}
				grp.close()
			end

			puts Messages.group_list_txt+fs_ext+"."
		end

		def listUsers(fs_ext = "", os="")
			if os === "" || fs_ext === ""
				puts "Invalid call to listUsers. Exiting."
				exit -1
			end

			user_list_txt_fin = []

			puts ""
			puts Messages.user_list_txt_fp

			case os
			when "windows"
				system(Cmd.wmic_usr + Messages.output_file_user + fs_ext)
			else
				Etc.passwd {|u| user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
				usr = File.open(Messages.output_file_user+fs_ext, "w")
				user_list_txt_fin.each { |usr_list| usr.write(usr_list)}
			end

			puts Messages.user_list_txt+fs_ext+"."
		end

		def listServices(fs_ext = "", os="")
			if os === "" || fs_ext === ""
				puts "Invalid call to listServices. Exiting."
				exit -1
			end

			listServicesCmd = ""

			puts ""
			puts Messages.services_txt

			case os
			when "ubuntu", "debian"
				listServicesCmd = "sudo service --status-all > #{Messages.output_file_services}#{fs_ext} 2>&1"
			when "redhat", "centos"
				listServicesCmd = "sudo chkconfig --list > #{Messages.output_file_services}#{fs_ext}"
			when "windows"
				listServicesCmd = wmic_srv + Messages.output_file_services + fs_ext
			else
				"Error. Unsupported os: #{os}. Exiting"
				exit -1
			end 

			system(listServicesCmd)
			puts Messages.services_finished+fs_ext+"."
		end

		def winReg(fs_ext = "")
			if fs_ext === ""
				puts "Invalid call to winReg. Exiting."
				exit -1
			end

			puts ""
			puts Messages.reg_fp
			Variables.reg_roots.each_with_index do |root, i|
				puts Messages.reg_fp_single(root, i, Variables.reg_roots.length)
				system(Cmd.winRegCmd + root + " /s >> registry." + fs_ext)
			end
			puts Messages.reg_fp_done + fs_ext
		end

		def fs_apt_file
			"apt-file list " + ARGV[0] + " | grep -e share -v | cut -d ' ' -f2 > " + ARGV[0] + ".package"
		end
		def apt_file_inst
			"sudo /usr/bin/apt-get install apt-file -y > /dev/null && /usr/bin/apt-file update > /dev/null"
		end
		def apt_file_inst_chk
			"sudo /usr/bin/apt-get install chkconfig -y > /dev/null"
		end
		def net_stat_nix
			"sudo /bin/netstat -tulpn > "
		end
		def net_stat_win
			"netstat > "
		end
		def fs_open
			File.open(Messages.fs_find_file+Variables.fs_ext[0], "w")
		end
		def exclude_and_write
			Find.find('/'){|path| fs_open.write(path + "\n")} #!= ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		end
		def close_file
			fs_open.close()
		end
		def wmic_grp
			"wmic GROUP > "
		end
		def wmic_usr 
			"wmic USERACCOUNT LIST FULL > "
		end
		def wmic_srv
			"wmic SERVICE LIST FULL > "
		end
		def winRegCmd
			"reg query "
		end
	end
end