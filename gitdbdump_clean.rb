#!/usr/bin/ruby

def connect_commits(left,right)
  puts "connecting #{left} to #{right}"
  `git checkout #{right} 2> /dev/null`
  `git reset --soft #{left} 2> /dev/null`
  `git commit -C #{right} 2> /dev/null`
  `git rebase --onto HEAD #{right} master 2> /dev/null`
end

## CONFIG

weekly = 0
daily = 31
hourly = 24*7

hour_step = 3600
day_step = 24*hour_step
week_step = 7*day_step

## BUILD DATE-RANGE

seconds_back = []
1.upto(hourly) do |step|
  seconds_back << step*hour_step
end

1.upto(daily) do |step|
  seconds_back << step*day_step
end

1.upto(weekly) do |step|
  seconds_back << step*week_step
end

seconds_back.uniq!.sort!

## GET ALL COMMITS AND SORT THEM BY TIME

list=`git log --pretty="%H %at %s"`
list = list.split("\n")
commits = []
list.each do |line|
  
  match = /^([^ ]*) ([^ ]*) (.*)$/.match(line)
  commit = {}
  commit[:sha] = match[1]
  commit[:time] = match[2].to_i
  commit[:msg] = match[3]

  commits << commit
end

commits.sort! {|a,b| a[:time] <=> b[:time]}

## CHECK SLICES FOR UNNECESSARY BACKUPS

now = Time.new.to_i

# add weeks
first_commit = commits[0]
i = 0
while (now - seconds_back.max) > first_commit[:time] 
  seconds_back << seconds_back.max + week_step 
  i = i + 1
end
puts "added #{i} weeks to reach beginning of history"

time_right = now
seconds_back.each do |back|
  time_left = now - back
  puts "window #{time_right - time_left} seconds, looking for commits between #{Time.at(time_left)} and #{Time.at(time_right)}"
  finds = commits.find_all {|c| c[:time] >= time_left && c[:time] < time_right}
  finds.sort! {|a,b| a[:time] <=> b[:time]}
  puts "found #{finds.size} commits"
  
  if (finds.size > 1)
    # connect first commit in window...
    left_end = finds.shift
    puts "left: #{left_end[:sha]} - #{left_end[:msg]}"
    # to first commit right after window
    right_end = commits.find {|c| c[:time] >= time_right} 
    if right_end.nil?
       puts "no commit outside of window"
       if (finds.size > 1)
           puts "using last commit in window"
           right_end = finds.pop 
       end
    end

    unless right_end.nil?
      puts "right: #{right_end[:sha]} - #{right_end[:msg]}"
      finds.each do |c|
        puts "deleting commit #{c[:sha]} - #{c[:msg]}"
      end
      connect_commits(left_end[:sha], right_end[:sha])
    end
  end

  time_right = time_left
end
