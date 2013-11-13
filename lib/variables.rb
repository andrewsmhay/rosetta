class Variables
	class << self
		def workingdir
			'.'
		end
		def inputter
			[]
		end
		def fs_ext
			['pre', 'post', 'out']
		end
		def opt_sel
			['pre', 'post', 'final']
		end
		def rc_list_txt_fin
			[]
		end
		def group_list_txt_fin
			[]
		end
		def user_list_txt_fin
			[]
		end
		def name_files
			['chkconfig','filesystem','group','services','user']
		end
		def package_name
			ARGV[0]
		end
		def package_rh
			"/usr/bin/yum"
		end
	end
end