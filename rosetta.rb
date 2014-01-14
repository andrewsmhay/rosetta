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

@os_select = Determineos.new
@os_decided = @os_select.os.to_s
@commands = []
ARGV.each {|arg| @commands << arg}
@rc_list_txt_fin = []
@group_list_txt_fin = []
@user_list_txt_fin = []
@filetype_ary = []

#############
# Footprint #
#############

def footprint_nix(fs_ext = "pre", os="")

	# Filesystem footprinting
	puts ""
	puts Messages.fs_footprint
	f = File.open(Messages.fs_find_file+fs_ext, "w")
	Find.find('/'){|path| f.write(path + "\n") unless ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
	f.close()
	puts Messages.fs_footprint_fin+fs_ext+"."

	# Network services
	puts ""
	puts Messages.net_stat_txt
	system(Cmd.net_stat+Messages.output_file_net_stat+fs_ext)
	puts Messages.net_stat_txt_fin+fs_ext+"."
	
	# Group information
	puts ""
	puts Messages.group_list_txt_fp
	Etc.group {|g| @group_list_txt_fin << g.name + ": " + g.mem.join(', ') + "\n"}
	grp = File.open(Messages.output_file_group+fs_ext, "w")
	@group_list_txt_fin.each {|grp_list| grp.write(grp_list)}
	grp.close()
	puts Messages.group_list_txt+fs_ext+"."
	
	# User information
	puts ""
	puts Messages.user_list_txt_fp
	Etc.passwd {|u| @user_list_txt_fin << u.name + " = " + u.gecos + "\n"}
	usr = File.open(Messages.output_file_user+fs_ext, "w")
	@user_list_txt_fin.each { |usr_list| usr.write(usr_list)}
	puts Messages.user_list_txt+fs_ext+"."
	
	# Services Information
	puts ""
	puts Messages.services_txt
	system(Cmd.list_services(os, Messages.output_file_services + "." + fs_ext))
	puts Messages.services_finished+fs_ext+"."
end

def final_compare_nix
	puts Messages.post_a_compare
	Variables.name_files.each do |naming|
		f1 = IO.readlines(Variables.workingdir + "/" + naming + ".pre").map(&:chomp)
		f2 = IO.readlines(Variables.workingdir + "/" + naming + ".post").map(&:chomp)
		File.open(Variables.workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
	end
	
	puts Messages.prob_config

	IO.readlines(Variables.workingdir + "/filesystem.out").map(&:chomp).each do |filetype|
		if filetype =~ /\.conf/
			@filetype_ary << filetype
		elsif filetype =~ /\.properties/
			@filetype_ary << filetype
		elsif filetype =~ /\.config/
			@filetype_ary << filetype
		elsif filetype =~ /\.xml/
			@filetype_ary << filetype
		elsif filetype =~ /\.json/
			@filetype_ary << filetype
		end
		File.open(Messages.output_filetype_ary+Variables.fs_ext[2], "w"){ |f| f.write((@filetype_ary).join("\n"))}
	end
	puts Messages.post_analysis
end


#####################
# Debian and Ubuntu #
#####################
if @os_decided == "nix" && File.exist?(Variables.package_deb)
	puts Messages.deb

	if ARGV[1] == Variables.opt_sel[0]
		fs_ext = Variables.fs_ext[0]

		# apt-file not used anywhere
		# unless !File.exist?(Variables.package_deb2)
		# 	puts Messages.apt_present
		# 	unless system(Cmd.apt_file_inst)
		# 		puts "Error during installation. Exiting."
		# 		exit -1
		# 	end
		# end

		# chkconfig no longer supported in Ubuntu
		# unless File.exist?(Variables.package_cc)
		# 	puts Messages.chkconfig_present
		# 	unless system(Cmd.apt_file_inst_chk)
		# 		puts "Error during installation. Exiting."
		# 		exit -1
		# 	end
		# end
		
		footprint_nix(fs_ext, "ubuntu")

	elsif ARGV[1] == Variables.opt_sel[1]
		fs_ext = Variables.fs_ext[1]
		puts Messages.post_fs_footprint

		footprint_nix(fs_ext, "ubuntu")

	else ARGV[1] == Variables.opt_sel[2]
		final_compare_nix
	end


######################
# Red Hat and CentOS #
######################
elsif @os_decided == "nix" && File.exist?(Variables.package_rh)
	if ARGV[1] == Variables.opt_sel[0]
		puts Messages.rh
		
		fs_ext = Variables.fs_ext[0]

		footprint_nix(fs_ext, "redhat")
		
	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint 
		
		fs_ext = Variables.fs_ext[1]
		
		footprint_nix(fs_ext, "redhat")
		
	else ARGV[1] == Variables.opt_sel[2]
		final_compare_nix
	end
	

#####################
# Microsoft Windows #
#####################
elsif @os_decided == "windows"
	if ARGV[1] == Variables.opt_sel[0]
		puts Messages.ms

		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		f = File.open(Messages.fs_find_file+Variables.fs_ext[0], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.file_footprint_done

		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat_win+Messages.output_file_net_stat+Variables.fs_ext[0])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[0]+"."

		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		system(Cmd.wmic_grp + Messages.output_file_group + Variables.fs_ext[0])
		puts Messages.group_list_txt+Variables.fs_ext[0]+"."

 		# User information
		puts ""
		puts Messages.user_list_txt_fp
		system(Cmd.wmic_usr + Messages.output_file_user + Variables.fs_ext[0])
		puts Messages.user_list_txt+Variables.fs_ext[0]+"."

		# Services Information
		puts ""
		puts Messages.services_txt
		system(Cmd.wmic_srv + Messages.output_file_services + Variables.fs_ext[0])
		puts Messages.services_txt_fin+Variables.fs_ext[0]+"."
	
		# Windows Registry
		puts ""
		puts Messages.reg_fp
		Variables.reg_roots.each_with_index do |root, i|
			puts Messages.reg_fp_single(root, i, Variables.reg_roots.length)
			system(Cmd.win_reg + root + " /s >> registry." + Variables.fs_ext[0])
		end
		puts Messages.reg_fp_done + Variables.fs_ext[0]

	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint

		# Filesystem footprinting
		puts ""
		puts Messages.fs_footprint
		f = File.open(Messages.fs_find_file+Variables.fs_ext[1], "w")
		Find.find('/'){|path| f.write(path + "\n") != ((path.start_with? ".") || (path.start_with? "/dev/") || (path.start_with? "/proc/") || (path.start_with? "/sys/") || (path.start_with? "/root/") || (path.start_with? "/usr/share/doc/") || (path.start_with? "/var/lib/yum") || (path.start_with? "/home"))}
		f.close()
		puts Messages.fs_footprint_fin+Variables.fs_ext[1]+"."

		# Network services
		puts ""
		puts Messages.net_stat_txt
		system(Cmd.net_stat_win+Messages.output_file_net_stat+Variables.fs_ext[1])
		puts Messages.net_stat_txt_fin+Variables.fs_ext[1]+"."

		# Group information
		puts ""
		puts Messages.group_list_txt_fp
		system(Cmd.wmic_grp + Messages.output_file_group + Variables.fs_ext[1])
		puts Messages.group_list_txt+Variables.fs_ext[1]+"."

		# User information
		puts ""
		puts Messages.user_list_txt_fp
		system(Cmd.wmic_usr + Messages.output_file_user + Variables.fs_ext[1])
		puts Messages.user_list_txt+Variables.fs_ext[1]+"."

		# Services Information
		puts ""
		puts Messages.services_txt
		system(Cmd.wmic_srv + Messages.output_file_services + Variables.fs_ext[1])
		puts Messages.services_txt_fin+Variables.fs_ext[1]+"."
		
		#Windows Registry
		puts ""
		puts Messages.reg_fp
		Variables.reg_roots.each_with_index do |root, i|
			puts Messages.reg_fp_single(root, i, Variables.reg_roots.length)
			system(Cmd.win_reg + root + " /s >> registry." + Variables.fs_ext[1])
		end
		puts Messages.reg_fp_done + Variables.fs_ext[1]

	else ARGV[1] == Variables.opt_sel[2]
		puts Messages.post_a_compare
		Variables.name_files.each do |naming|
			f1 = IO.readlines(Variables.workingdir + "/" + naming + ".pre").map(&:chomp)
			f2 = IO.readlines(Variables.workingdir + "/" + naming + ".post").map(&:chomp)
			File.open(Variables.workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\r\n")) }
		end

		# Registry has a different operation, so it's not part of the loop above
		reg_data_pre = File.open(Messages.output_file_reg + Variables.fs_ext[0]).read.split(/\n(?=HKEY)/).map(&:strip)
		reg_data_post = File.open(Messages.output_file_reg + Variables.fs_ext[1]).read.split(/\n(?=HKEY)/).map(&:strip)
		
		File.open(Variables.workingdir + "/" + Messages.output_file_reg + Variables.fs_ext[2], "w") do |f|
			f.write((reg_data_post - reg_data_pre).join("\r\n"))
		end

		puts Messages.post_analysis
	end
	
else
  puts Messages.opt_sel_err
end