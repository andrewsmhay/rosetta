puts Messages.post_a_compare
Variables.name_files.each do |naming|
	f1 = IO.readlines(Variables.workingdir + "/" + naming + ".pre").map(&:chomp)
	f2 = IO.readlines(Variables.workingdir + "/" + naming + ".post").map(&:chomp)
	File.open(Variables.workingdir + "/" + naming + ".out", "w"){ |f| f.write((f2 - f1).join("\n")) }
end
puts Messages.post_analysis