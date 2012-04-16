%w(lib ../lib . ..).each{|d| $:.unshift(d)}
require 'etc'

###############################################################################
# example of ETC::PASSWD usage
###############################################################################

puts 'ETC::PASSWD'
puts '---'

ETC::PASSWD.each_with_index do |entry, i|
  puts entry
  break if i > 5
end
puts '---'

r = rand ETC::PASSWD.size 
user = ETC::PASSWD.entries[r]

puts "USER #{user} CHOSEN AT RANDOM"
puts '---'

name = user.name
uid = user.uid

printf "ETC::PASSWD[%s] -> [%s]\n", name, ETC::PASSWD[name]
puts '---'

printf "ETC::PASSWD[%d] -> [%s]\n", uid, ETC::PASSWD[uid]
puts '---'

puts ETC::PASSWD.max
puts '---'

puts ETC::PASSWD.min
puts '---'

puts 'ETC::GROUP'
puts '---'


###############################################################################
# example of ETC::GROUP usage
###############################################################################

ETC::GROUP.each_with_index do |entry, i|
  puts entry
  break if i > 5
end
puts '---'

r = rand ETC::GROUP.size 
group = ETC::GROUP.entries[r]

puts "GROUP #{group} CHOSEN AT RANDOM"
puts '---'

name = group.name
gid = group.gid

printf "ETC::GROUP[%s] -> [%s]\n", name, ETC::GROUP[name]
puts '---'

printf "ETC::GROUP[%d] -> [%s]\n", gid, ETC::GROUP[gid]
puts '---'

puts ETC::GROUP.max
puts '---'

puts ETC::GROUP.min
puts '---'
