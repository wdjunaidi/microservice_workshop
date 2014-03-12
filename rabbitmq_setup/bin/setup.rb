#!/usr/bin/env ruby
# encoding: utf-8

def vhost label
  `rabbitmqadmin declare vhost name='#{label}'`
  puts "vhost #{label} created"
end

def user label, role = 'Monitoring'  # Admin Monitoring Policymaker Management None
  user_password label, label, role
end

def user_password name, password, roles = 'Admin, Monitoring, Policymaker, Management'
  `rabbitmqadmin declare user name='#{name}' password='#{password}' tags='#{roles}'`
  puts "user #{name} created with password and role(s): #{roles}"
end

def permission vhost, user = vhost
  `rabbitmqadmin declare permission vhost='#{vhost}' user='#{user}' configure='.*' write='.*' read='.*'`
  puts "permission for user #{user} to access vhost #{vhost}"
end

def fanout_exchange label
  `rabbitmqadmin declare exchange name='#{label}_rapids' type=fanout vhost='#{label}'`
  puts "rabbitmqadmin declare exchange name='#{label}_rapids' type=fanout vhost='#{label}'"
  puts "fanout exchange '#{label}_exchange' for vhost #{label}"
end

user_password 'fred', 'booster2014'
permission '/', 'fred'
`rabbitmqadmin declare exchange name='rapids' type=fanout`

%w[
    bugs
    roger jessica
    peter
    white
    yogi booboo
    daffy
    hewey lewey dewey
    donald daisy
    pluto goofy
    mickey minnie
    tweety porky
    garfield
    peabody
    tom jerry
    woody
    elmer
    homer marge bart lisa
  ].each do |label|
    puts "\nSetting up for #{label}..."
    vhost label
    user label
    permission label
    permission label, 'fred'
    permission label, 'guest'
    fanout_exchange label
end
