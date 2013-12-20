=begin
  
Author: Junyi Shi
Version: 1.0
Organization: EMC Corporation
Date Created: 10/30/2013.

Description: This is a simple script for create/update/delete release. Once a time.
  
=end

require 'rally_api_emc_sso' 
require 'Date'
require 'net/http'

headers = RallyAPI::CustomHttpHeader.new()
headers.name = 'My Utility'
headers.vendor = 'MyCompany'
headers.version = '1.0'

@project = "Jenny-test"

#==================== Making a connection to Rally ====================
#config = {:base_url => "https://rally1.rallydev.com/slm"}

config = {:workspace => "Workspace 1"}
config[:domain] = 'corp.emc.com'
config[:project] = @project
config[:headers] = headers #from RallyAPI::CustomHttpHeader.new()
config[:jsession_id_path] = 'jsessionid.txt'

@rally = RallyAPI::RallyRestJson.new(config)

#check http://developer.help.rallydev.com/ruby-toolkit-rally-rest-api-json 
#use the example on this page from "Querying Rally" 

def find_project(project_name)
  query = RallyAPI::RallyQuery.new()
  query.type = :project
  query.fetch = "Name"
  query.query_string = "(Name = \"#{project_name}\")"
  result = @rally.find(query)

  if(result.length != 0)
    puts "find the project #{project_name}"
  else 
    puts "project #{project_name} not found"
    exit
  end
  result
end

def find_release(release_name,project_name,start_date,end_date)
  query = RallyAPI::RallyQuery.new()
  query.type = :release   
  query.fetch = "Name,Project"
  query.project_scope_up = true
  query.project_scope_down = true
  query.order = "Name Asc"
  query.query_string = "(((Name = \"#{release_name}\")AND(Project.Name = \"#{project_name}\"))AND(ReleaseStartDate = \"#{start_date}\"))"

  results = @rally.find(query)
  
  #query = RallyAPI::RallyQuery.new({:type => :release ,:query_string => "(Name = \"release #{release_name}\")"})
  #results = build_query("release","Name","","((Name = \"#{release_name}\")AND(Project.Name = \"#{project_name}\"))") 
  if (results.length == 0)
    puts "#{release_name} not found"
    #exit
  else
    puts "Release #{release_name} found"
    results.each do |result|
      result.read
    
      puts "Name: #{result.Name}"
      puts "Project: #{result.Project}"
      puts "Start Date: #{result.ReleaseStartDate}"
      puts "End Date: #{result.ReleaseDate}"
      puts "State : #{result.State}"
    end
  end
  results
end
 
def read_release(release_name,project_name)
  query = RallyAPI::RallyQuery.new()
  query.type = :release   
  query.fetch = "Name,Project"
  query.project_scope_up = true
  query.project_scope_down = true
  query.order = "Name Asc"
  query.query_string = "((Name = \"#{release_name}\")AND(Project.Name = \"#{project_name}\"))"

  results = @rally.find(query)
  
  if (results.length == 0)
    puts "#{release_name} not found"
    #exit
  else
    puts "Release #{release_name} found"
  end
  results
end

def create_release(release_name, project_name,start_date,end_date)
  puts "Creating..."
  field = {}
  field["Name"] = release_name
  field["Project.Name"] = project_name
  field["ReleaseStartDate"] = start_date
  field["ReleaseDate"] = end_date
  field["State"] = "Planning"
  create_release = @rally.create("release",field)
  puts "#{release_name} created"
end

def update_release(release_name,project_name,start_date,end_date,state)
  puts "Updating..."
  field = {}
  field["Name"] = release_name
  field["Project.Name"] = project_name
  field["ReleaseStartDate"] = start_date
  field["ReleaseDate"] = end_date
  field["State"] = state
   @rally.update("release","#{@release["_ref"]}",field)
  puts "#{release_name} updated"
end

=begin
def delete_release(release_name,project_name,start_date,end_date)
  puts "Deleting..."
  @rally.delete(@release["_ref"])
  puts "#{release_name} deleted"
end
=end

def start

  command = ARGV[0]
  release_name = ARGV[1]
  project_name = ARGV[2]
  start_date = ARGV[3]
  end_date = ARGV[4]
  state = ARGV[5]
  #new_name = ARGV[6].strip

  
  #release_name2 = "release #{release_name}"
  #puts release_name2
  #project = find_project(project_name,name)
  #get_auth_cookies

  if(command == "create")
    if ARGV.size != 6
      puts "usage: ruby #{__FILE__} <command> <release_name> <project_name> <start_date> <end_date> <state>"
      exit
    end
    find_project(project_name)
    result = find_release(release_name,project_name,start_date,end_date)
    if (result.length == 0)
      create_release(release_name,project_name,start_date,end_date)
      else
        puts "Can't create, the same release exists!"
    end
  end


  if(command == "update")
    if ARGV.size != 7
      puts "usage: ruby #{__FILE__} <command> <release_name> <project_name> <start_date> <end_date> <state> <new_name>"
     exit
    end
    find_project(project_name)
    new_name = ARGV[6].strip
    
    result = find_release(release_name,project_name,start_date,end_date)
    #@release = result.first
    #puts @release["_ref"]
    if (result.length != 0)
      @release = result.first
      puts @release["_ref"]
      update_release(new_name,project_name,start_date,end_date, state)
      else
        puts "Can't update, the release doesn't exist!"
    end
  end

=begin 
  if(command == "delete")
    if ARGV.size != 6
      puts "usage: ruby #{__FILE__} <command> <release_name> <project_name> <start_date> <end_date> <state>"
      exit
    end
    find_project(project_name)
    result = find_release(release_name,project_name,start_date,end_date)
    if (result.length != 0)
      @release = result.first
      puts @release["_ref"]
      delete_release(release_name,project_name,start_date,end_date)
      else
        puts "Can't delete, the release doesn't exist!"
    end
  end
=end

  if(command == "read")
    if ARGV.size != 3
      puts "usage: ruby #{__FILE__} <command> <release_name> <project_name>"
      exit
    end
    find_project(project_name)
    result = read_release(release_name,project_name)
    if (result.length != 0)
      result.each do |res|
        res.read
        time = res.ReleaseDate
        puts time
        puts "Name:    #{res.Name}"
        puts "Project: #{res.Project}"
        puts "Start Date: #{res.ReleaseStartDate}"
        puts "End Date: #{res.ReleaseDate}"
        puts "State : #{res.State}"
        puts "\n"
      end
    end
  end
end

start
