#!/usr/bin/ruby

require 'rubygems'
require 'mail'
require 'etc'

# parse Mail
mail = Mail.new(ARGF.read)
group = Etc.getgrnam(mail['delivered_to'].value.gsub(/@.*/,""))

# recipients in group
recipients = group.mem

# recipients which have target-group as their homegroup
Etc.passwd do |entry|
  recipients << entry.name if entry.gid == group.gid
end

# close /etc files
Etc.endgrent()
Etc.endpwent()

`echo "#{mail.raw_source}" | sendmail #{recipient.uniq.join(" ")}`