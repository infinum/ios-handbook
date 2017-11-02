file = ARGV[0]
File.readlines(file).each do |line|
	puts line if (line=~/\d{4,20}\.\d*ms/)
end