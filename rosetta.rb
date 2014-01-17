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
@filetype_ary = []


#############
# Footprint #
#############

def footprint(fs_ext = "pre", os="")

	# Filesystem footprinting
	Cmd.fs_footprint(fs_ext, os)

	# Network services
	Cmd.netstat(fs_ext, os)
	
	# Group information
	Cmd.listGroups(fs_ext, os)
	
	# User information
	Cmd.listUsers(fs_ext, os)
	
	# Services Information
	Cmd.listServices(fs_ext, os)

	if os === "windows"
		#Windows Registry
		Cmd.winReg(fs_ext)
	end
end

def cmpSingle(fName="")
	if fName === ""
		puts "Invalid call to cmpSingle. Need a file name. Exiting."
		exit -1
	end

	f1 = IO.readlines(Variables.workingdir + "/" + fName + ".pre").map(&:strip)
	f2 = IO.readlines(Variables.workingdir + "/" + fName + ".post").map(&:strip)
	File.open(Variables.workingdir + "/" + fName + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
end

# delim should be a regex pattern
def cmpMulti(fName="", delim="")
	if fName === "" || delim === ""
		puts "Invalid call to cmpSingle. Need a file name and a delimiting pattern. Exiting."
		exit -1
	end

	data_pre = File.open(fName + Variables.fs_ext[0]).read.split(/#{delim}/).map(&:strip)
	data_post = File.open(fName + Variables.fs_ext[1]).read.split(/#{delim}/).map(&:strip)
	
	File.open(Variables.workingdir + "/" + fName + Variables.fs_ext[2], "w") do |f|
		f.write((data_post - data_pre).join("\n\n"))
	end
end

def final_compare_nix
	# All single line comparisons, so just do a line-by-line set difference.
	puts Messages.post_a_compare
	Variables.name_files.each do |naming|
		cmpSingle(naming)
	end
	
	puts Messages.prob_config

	IO.readlines(Variables.workingdir + "/filesystem.out").map(&:strip).each do |filetype|
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

def final_compare_win
	puts Messages.post_a_compare
	# Variables.name_files.each do |naming|
	# 	f1 = IO.readlines(Variables.workingdir + "/" + naming + ".pre").map(&:chomp)
	# 	f2 = IO.readlines(Variables.workingdir + "/" + naming + ".post").map(&:chomp)
	# 	File.open(Variables.workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
	# end

	# Filesystem, netstat, and groups are single-line output
	cmpSingle("filesystem")
	cmpSingle("net_services")
	cmpSingle("group")

	# Users, service, and registry have multiline output, and require a delimiter to diff the entries
	cmpMulti(Messages.output_file_user, "\\n(?=AccountType)")
	cmpMulti(Messages.output_file_services, "\\n(?=AcceptPause)")
	cmpMulti(Messages.output_file_reg, "\\n(?=HKEY)")
	

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
		
		footprint(fs_ext, "ubuntu")

	elsif ARGV[1] == Variables.opt_sel[1]
		fs_ext = Variables.fs_ext[1]
		puts Messages.post_fs_footprint

		footprint(fs_ext, "ubuntu")

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

		footprint(fs_ext, "redhat")
		
	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint 
		
		fs_ext = Variables.fs_ext[1]
		
		footprint(fs_ext, "redhat")
		
	else ARGV[1] == Variables.opt_sel[2]
		final_compare_nix
	end

############
# Mac OS X #
############
elsif @os_decided == "mac"
	if ARGV[1] == Variables.opt_sel[0]
		puts Messages.mac
		
		fs_ext = Variables.fs_ext[0]

		footprint(fs_ext, "mac")
		
	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint 
		
		fs_ext = Variables.fs_ext[1]
		
		footprint(fs_ext, "mac")
		
	else ARGV[1] == Variables.opt_sel[2]
		final_compare_nix
	end
	

#####################
# Microsoft Windows #
#####################
elsif @os_decided == "windows"
	if ARGV[1] == Variables.opt_sel[0]
		puts Messages.ms

		fs_ext = Variables.fs_ext[0]

		footprint(fs_ext, "windows")

	elsif ARGV[1] == Variables.opt_sel[1]
		puts Messages.post_fs_footprint

		fs_ext = Variables.fs_ext[1]

		footprint(fs_ext, "windows")

	else ARGV[1] == Variables.opt_sel[2]
		final_compare_win
	end
	
else
  puts Messages.opt_sel_err
end