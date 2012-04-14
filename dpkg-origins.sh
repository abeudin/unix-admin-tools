#!/usr/bin/ruby

arch = `lscpu`.split("\n")[0].split(" ")[1]
if arch == "x86_64"
    arch = "amd64"
else
    arch = "i386"
end

repos = {}

list = `dpkg-query -l`.split("\n")
list = list[5..-1]
list.each do |line|
    pkg = line.split(" ")
    status = pkg[0]
    name = pkg[1]
    version = pkg[2].gsub(/.*:/,"") # remove epoch
    desc = pkg[3..-1].join(" ")
    
    if (status.include? "i")
        result = `grep "/#{name}_#{version}_.*.deb" /var/lib/apt/lists/*#{arch}*Packages*`     
        package = {:name => name, :version => version, :desc => desc}
        
        if (result.empty?)
            repos[""] = [] if repos[""].nil?
            repos[""] << package
        else
            result = result.split("\n")
            result.each do |r|
                reponame = r.gsub(/_binary.*/,"").gsub("/var/lib/apt/lists/","")
                repos[reponame] = [] if repos[reponame].nil?
                repos[reponame] << package
            end
        end
    end
end

repo_keys = repos.keys.sort
if repo_keys.include? ""
    repo_keys.delete("")
    repo_keys << ""
end

repo_keys.each do |reponame|
    if reponame.empty?
        puts ""
        puts ""
        puts "not found in any repository"
    else
        puts ""
        puts ""
        puts "#{reponame}:"
    end
    puts ""
    pkgs = repos[reponame]
    pkgs.sort! {|a,b| a[:name] <=> b[:name]}
    
    pkgs.each do |pkg|
        puts "".ljust(5) + pkg[:name].ljust(40) + pkg[:version].ljust(40) + pkg[:desc]
    end
end
puts ""