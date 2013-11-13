class Cmd
	class << self
		def fs_apt_file
			"apt-file list " + ARGV[0] + " | grep -e share -v | cut -d ' ' -f2 > " + ARGV[0] + ".package"
		end
		def apt_file_inst
			"/usr/bin/apt-get install apt-file -y > /dev/null && /usr/bin/apt-file update > /dev/null"
		end
		def apt_file_inst_chk
			"/usr/bin/apt-get install chkconfig -y > /dev/null"
		end
		def net_stat
			"/bin/netstat -tulpn > "
		end
		def net_stat_win
			"netstat > "
		end
		def chk_config
			"chkconfig --list > "
		end
		def fs_open
			File.open(Messages.fs_find_file+Variables.fs_ext[0], "w")
		end
		def exclude_and_write
			Find.find('/'){|path| fs_open.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		end
		def close_file
			f.close()
		end
	end
end