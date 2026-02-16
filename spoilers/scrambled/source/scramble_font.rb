#!/usr/bin/env ruby


font = File.readlines("font8x8u.asm")

chars = font[1..-1]

flag         = "this crypto module supports colors".split("")
replacements = "ACFGHJKLMNPQRTUVWXZ1234567890!%&.:".split("").shuffle


scramble = {}

replacements.each_with_index do |r, i|
	scramble[r] = flag[i]
end

puts scramble

puts "DISOBEY[#{flag.join("")}]"
puts "DISOBEY[#{replacements.join("")}]"

scramble.each_pair do |k, v|
	chars[k.ord] = chars[v.ord]
end

File.open("scrambled_font.asm", "w") do |f|
	f.write font[0]
	chars.each do |c|
		f.write c
	end
end