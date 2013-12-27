=begin
  
Author: Junyi Shi
Version: 1.0
Organization: EMC Corporation
Date Created: 11/01/2013.

Description: This is a simple script for create/update/delete release. Once a time.
  
=end

require 'rally_api' 
require 'date'
class Release_CRUD
  
  def initialize (workspace,project)
    headers = RallyAPI::CustomHttpHeader.new()
    headers.name = 'My Utility'
    headers.vendor = 'MyCompany'
    headers.version = '1.0'

    #==================== Making a connection to Rally ====================
    config = {:base_url => "https://rally1.rallydev.com/slm"}
    config = {:workspace => workspace}
    config[:project] = project
    config[:headers] = headers #from RallyAPI::CustomHttpHeader.new()

    @rally = RallyAPI::RallyRestJson.new(config)
    #puts "Workspace #{@workspace}"
    #puts "Project #{@project}"
  end
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
    #exit
  end
  result
end

def find_release(row)
  
  query = RallyAPI::RallyQuery.new()
  query.type = :release   
  query.fetch = "Name,Project"
  query.project_scope_up = true
  query.project_scope_down = true
  query.order = "Name Asc"

  name = row["Name"]
  project = row["Project"]
  start_date = Date.strptime(row["Start Date"],'%m/%d/%Y').iso8601
  
  query.query_string = "(((Name = \"#{name}\")AND(Project.Name = \"#{project}\"))AND(ReleaseStartDate = \"#{start_date}\"))"
  
  results = @rally.find(query)
  #query = RallyAPI::RallyQuery.new({:type => :release ,:query_string => "(Name = \"release #{release_name}\")"})
  #results = build_query("release","Name","","((Name = \"#{release_name}\")AND(Project.Name = \"#{project_name}\"))") 
  if (results.length == 0)
    puts "#{row["Name"]} not find"
    #exit
  else
    puts "Find Release: #{row["Name"]}"
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

def update_release(row)
  puts "Managing row #{@iCount}"
  puts "Updating..."
  #result = find_project(row["Project"])
  if( find_project(row["Project"])!= nil)
    result = find_release(row)
    if(result.length != 0)
      @release = result.first
      puts @release["_ref"]
      field = {}
      
      if (row["New Name"] != nil)
        field["Name"] = row["New Name"]
        @rally.update("release","#{@release["_ref"]}",field)
        puts "#{row["Name"]} updated"

      end
  
      if (row["New Project"] != nil)
        res = find_project(row["New Project"])
        @res = res.first
        field["Project"] = @res["_ref"]
        @rally.update("release","#{@release["_ref"]}",field)
        puts "#{row["Name"]} updated"

      end
      
      if (row["New Start Date"] != nil)
        field["ReleaseStartDate"] = Date.strptime(row["New Start Date"],'%m/%d/%Y').iso8601
        @rally.update("release","#{@release["_ref"]}",field)
        puts "#{row["Name"]} updated"

      end
      
      if (row["New End Date"] != nil)
        field["ReleaseDate"] = Date.strptime(row["New Release Date"],'%m/%d/%Y').iso8601
        @rally.update("release","#{@release["_ref"]}",field)
        puts "#{row["Name"]} updated"
 
      end
    end
  end
end



def delete_release(row)
  puts "Managing row #{@iCount}"
  puts row["Project"]
  if(find_project(row["Project"]) != nil)
    result = find_release(row["Name"],row["Project"],Date.strptime(row["Start Date"],'%m/%d/%Y').iso8601,Date.strptime(row["End Date"],'%m/%d/%Y').iso8601)
    if(result.length != 0)
      @release = result.first
      puts @release["_ref"]
      puts "Deleting..."
      @rally.delete(@release["_ref"])
      puts "#{row["Name"]} deleted"
    end
  end
end

def create_release(row)
  puts "Creating..."
#  puts row["Name"]
  result = find_project(row["Project"])
  @project = result.first
  puts @project["_ref"]
  field = {}
  field["Name"] = row["Name"]
  field["Project"] = @project["_ref"]
  field["ReleaseStartDate"] = Date.strptime(row["Start Date"],'%m/%d/%Y').iso8601
  field["ReleaseDate"] = Date.strptime(row["Release Date"],'%m/%d/%Y').iso8601
  field["State"] = row["State"]
  @rally.create("release",field)
  puts "#{row["Name"]} created"
  puts "\n"
  return true
end

def create_release_for_child(row)
  #find_all_children(row["Project"])

  puts "Creating..."
  @array = []
  results = find_all_children(row["Project"])
  puts results

  results.each do |result|
#    result.read
#    puts "Project : #{result.Name}"
    
    result = find_project("#{result.Name}")
    @project = result.first
    puts @project["_ref"]
    field = {}
    field["Name"] = row["Name"]
    field["Project"] = @project["_ref"]
    field["ReleaseStartDate"] = Date.strptime(row["Start Date"],'%m/%d/%Y').iso8601
    field["ReleaseDate"] = Date.strptime(row["Release Date"],'%m/%d/%Y').iso8601
    field["State"] = row["State"]
    @rally.create("release",field)
    puts "#{row["Name"]} created"
    puts "\n"
  end  

end

def find_all_children(project_name)
    query = RallyAPI::RallyQuery.new()
    query.type = :project
    query.fetch = "Name,Children,State"
    query.query_string = "((Name = \"#{project_name}\")AND(State = \"Open\"))"
    result = @rally.find(query)
    
    result.each do |res|
      res.read
      #puts "Results :#{res}"
      if(res.Children.results == nil)
        @array.push(res)
      else
        @array.push(res)
        res.Children.results.each{|c|
          c.read
          if (c.State == "Open")
            find_all_children("#{c.Name}")            
          end
        }
       end
     end
 end
end