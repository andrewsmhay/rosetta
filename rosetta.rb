#!/usr/bin/env ruby
libdir = File.expand_path(File.dirname(__FILE__) + "/lib")
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

#gems
require 'etc'
require 'fileutils'
require 'find'
require 'ostruct'
require 'rspec'
# libs
require 'determineos'
require 'messages'
require 'variables'
require 'cmd'

@options = OpenStruct.new
@options.stage = ""
@options.fs = false
@options.net = false
@options.group = false
@options.user = false
@options.service = false
@options.reg = false

@os_select = Determineos.new
@os_decided = @os_select.os.to_s
@commands = []
ARGV.each {|arg| @commands << arg}
@rc_list_txt_fin = []
@filetype_ary = []

def optsAllFalse
	@options.fs == false &&
	@options.net == false &&
	@options.group == false &&
	@options.user == false &&
	@options.service == false &&
	@options.reg == false
end

#### Command Line Options ####
optparse = OptionParser.new do |opts|
  opts.banner = "Footprint various system components before and after software installation and compare " \
  "results to see system changes.\n\nUsage: './rosetta.rb [options] <pre|post|final>'. If no options are specified, all footprints are run."

  opts.on("-f", "--filesystem", "Footprint the entire root filesystem.") do
    @options.fs = true
  end

  opts.on("-n", "--netstat", "Run netstat to gather network stats.") do
    @options.net = true
  end

  opts.on("-g", "--group", "List the system's groups.") do
    @options.group = true
  end

  opts.on("-u", "--user", "List the system's users.") do
    @options.user = true
  end

  opts.on("-s", "--service", "List the system's services.") do
    @options.service = true
  end

  opts.on("-r", "--registry", "Dump the Windows registry.") do
    @options.reg = true
  end

  opts.on("-R", "--no-registry", "Run every footprint except the Windows registry.") do
    @options.fs = true
		@options.net = true
		@options.group = true
		@options.user = true
		@options.service = true
  end

  opts.on_tail("-h", "--help", "Show help text") do
    $stderr.puts opts
    exit
  end
end
optparse.parse!

# if the options are all false at this point, then no options have been passed, so do all footprints.
if optsAllFalse
  @options.fs = true
	@options.net = true
	@options.group = true
	@options.user = true
	@options.service = true
	@options.reg = true
end

# final arguments check for stage of rosetta footprinting
if ARGV.length != 1 || (ARGV[0] =~ /^(pre|post|final)$/) == nil
	$stderr.puts "Invalid invocation."
	$stderr.puts optparse.help
	exit -1
else
	@options.stage = ARGV[0]
end

#### End of options parsing ####

# Check for data directories
Variables.fs_ext.each do |dir|
	unless File.exist?("./" + dir)
		FileUtils.mkdir_p("./" + dir)
	end
end


#############
# Footprint #
#############

def footprint(fs_ext = "pre", os="")

	# Filesystem footprinting
	Cmd.fs_footprint(fs_ext, os) if @options.fs

	# Network services
	Cmd.netstat(fs_ext, os) if @options.net
	
	# Group information
	Cmd.listGroups(fs_ext, os) if @options.group
	
	# User information
	Cmd.listUsers(fs_ext, os) if @options.user
	
	# Services Information
	Cmd.listServices(fs_ext, os) if @options.service

	if os === "windows"
		#Windows Registry
		Cmd.winReg(fs_ext) if @options.reg
	end
end

def cmpSingle(fName="")
	if fName === ""
		puts "Invalid call to cmpSingle. Need a file name. Exiting."
		exit -1
	end

	f1 = IO.readlines("./pre/" + fName + "pre").map(&:strip)
	f2 = IO.readlines("./post/" + fName + "post").map(&:strip)
	File.open("./out/" + fName + "out", "w"){ |f| f.write((f2 - f1).join("\n")) }
end

# delim should be a regex pattern
def cmpMulti(fName="", delim="")
	if fName === "" || delim === ""
		puts "Invalid call to cmpSingle. Need a file name and a delimiting pattern. Exiting."
		exit -1
	end

	data_pre = File.open("./pre/" + fName + Variables.fs_ext[0]).read.split(/#{delim}/).map(&:strip)
	data_post = File.open("./post/" + fName + Variables.fs_ext[1]).read.split(/#{delim}/).map(&:strip)
	
	File.open("./out/" + fName + Variables.fs_ext[2], "w") do |f|
		f.write((data_post - data_pre).join("\n\n"))
	end
end

def final_compare_nix
	puts Messages.post_a_compare

	# All single line comparisons, so just do a line-by-line set difference.
	cmpSingle(Messages.fs_find_file) if @options.fs
	cmpSingle(Messages.output_file_net_stat) if @options.net
	cmpSingle(Messages.output_file_group) if @options.group
	cmpSingle(Messages.output_file_user) if @options.user
	cmpSingle(Messages.output_file_services) if @options.service
	
	puts Messages.prob_config

	IO.readlines("./out/filesystem.out").map(&:strip).each do |filetype|
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
		File.open("./out/" + Messages.output_filetype_ary+Variables.fs_ext[2], "w"){ |f| f.write((@filetype_ary).join("\n"))}
	end
	puts Messages.post_analysis
end

def final_compare_win
	puts Messages.post_a_compare

	# Filesystem, netstat, and groups are single-line output
	cmpSingle(Messages.fs_find_file)
	cmpSingle(Messages.output_file_net_stat)
	cmpSingle(Messages.output_file_group)

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

	if @options.stage == Variables.opt_sel[0]
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

	elsif @options.stage == Variables.opt_sel[1]
		fs_ext = Variables.fs_ext[1]
		puts Messages.post_fs_footprint

		footprint(fs_ext, "ubuntu")

	else @options.stage == Variables.opt_sel[2]
		final_compare_nix
	end


######################
# Red Hat and CentOS #
######################
elsif @os_decided == "nix" && File.exist?(Variables.package_rh)
	if @options.stage == Variables.opt_sel[0]
		puts Messages.rh
		
		fs_ext = Variables.fs_ext[0]

		footprint(fs_ext, "redhat")
		
	elsif @options.stage == Variables.opt_sel[1]
		puts Messages.post_fs_footprint 
		
		fs_ext = Variables.fs_ext[1]
		
		footprint(fs_ext, "redhat")
		
	else @options.stage == Variables.opt_sel[2]
		final_compare_nix
	end

############
# Mac OS X #
############
elsif @os_decided == "mac"
	if @options.stage == Variables.opt_sel[0]
		puts Messages.mac
		
		fs_ext = Variables.fs_ext[0]

		footprint(fs_ext, "mac")
		
	elsif @options.stage == Variables.opt_sel[1]
		puts Messages.post_fs_footprint 
		
		fs_ext = Variables.fs_ext[1]
		
		footprint(fs_ext, "mac")
		
	else @options.stage == Variables.opt_sel[2]
		final_compare_nix
	end
	

#####################
# Microsoft Windows #
#####################
elsif @os_decided == "windows"
	if @options.stage == Variables.opt_sel[0]
		puts Messages.ms

		fs_ext = Variables.fs_ext[0]

		footprint(fs_ext, "windows")

	elsif @options.stage == Variables.opt_sel[1]
		puts Messages.post_fs_footprint

		fs_ext = Variables.fs_ext[1]

		footprint(fs_ext, "windows")

	else @options.stage == Variables.opt_sel[2]
		final_compare_win
	end
	
else
  puts Messages.opt_sel_err
end