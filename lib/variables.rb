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
			['services','filesystem','group','net_services','user']
		end
		def package_name
			ARGV[0]
		end
		def package_rh
			"/usr/bin/yum"
		end
		def package_deb
			"/usr/bin/apt-get"
		end
		def package_deb2
			"/usr/bin/apt-file"
		end
		def package_cc
			"/sbin/chkconfig"
		end
		def delim
			['=',';',':',' ','|']
		end
		def comment
			['#','//','/*','*/','*','='] 
		end
		def reg_roots
			["HKLM", "HKCU", "HKCR", "HKU", "HKCC"]
		end
	end
end