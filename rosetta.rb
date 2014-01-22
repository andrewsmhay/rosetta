#!/usr/bin/env ruby
fPath = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
libdir = File.expand_path(File.dirname(fPath) + "/lib")
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

#gems
require 'diffy'
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
  	if @os_decided != "windows"
  		$stderr.puts "Error: Not on a Windows system. Cannot footprint the registry."
  		exit -1
  	else
    	@options.reg = true
    end
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

def diff(fName="")
	if fName === ""
		puts "Invalid call to diff. Need a file name and a delimiting pattern. Exiting."
		exit -1
	end

	diffData = Diffy::Diff.new("./pre/" + fName + Variables.fs_ext[0], "./post/" + fName + Variables.fs_ext[1],
		:source => 'files', :include_diff_info => true, :context => 3).to_s(:text)
	File.open("./out/" + fName + Variables.fs_ext[2], "w") { |f| f.write(diffData) } unless diffData.empty?
end

def final_compare
	puts Messages.post_a_compare

	diff(Messages.fs_find_file) if @options.fs
	diff(Messages.output_file_net_stat) if @options.net
	diff(Messages.output_file_group) if @options.group
	diff(Messages.output_file_user) if @options.user
	diff(Messages.output_file_services) if @options.service
	diff(Messages.output_file_reg) if @options.reg
	
	puts Messages.prob_config

	if @options.fs
		config_changed = false
		IO.readlines("./out/filesystem.out").map(&:strip).each do |filetype|
			if filetype =~ /^(\+|-).+(\.conf|\.properties|\.config|\.xml|\.json)$/
				config_changed = true
				@filetype_ary << filetype

			# keep diff info
			elsif filetype =~ /---.+$|\+\+\+.+$|^@@.+@@$/
				# if the last line added was also section info, then there were no config files in that section,
				# so write over the last index instead of appending
				if @filetype_ary[-1] =~ /^@@.+@@$/
					@filetype_ary[-1] = filetype
				else
					@filetype_ary << filetype
				end
			end
		end

		# remove sections with no changes concerning config files
		if config_changed
			while @filetype_ary[-1] =~ /^@@.+@@$/
				@filetype_ary.pop
			end
		
			File.open("./out/" + Messages.output_filetype_ary+Variables.fs_ext[2], "w") do |f|
				f.write((@filetype_ary).join("\n"))
			end
		end

		puts Messages.post_analysis
	end
end


#####################
# Debian and Ubuntu #
#####################
if @os_decided == "nix" && File.exist?(Variables.package_deb)
	puts Messages.deb

	if @options.stage == Variables.opt_sel[0]
		fs_ext = Variables.fs_ext[0]
		
		footprint(fs_ext, "ubuntu")

	elsif @options.stage == Variables.opt_sel[1]
		fs_ext = Variables.fs_ext[1]
		puts Messages.post_fs_footprint

		footprint(fs_ext, "ubuntu")

	else @options.stage == Variables.opt_sel[2]
		final_compare
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
		final_compare
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
		final_compare
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
		final_compare
	end
	
else
  puts Messages.opt_sel_err
end