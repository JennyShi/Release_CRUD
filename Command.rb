require 'rally_api_emc_sso'
require 'csv'

require './Release_CRUD.rb'

# Default workspace is set to "Workspace 1" and project is set to "Rohan-test"
def start
  puts "Enter Workspace: 1. Workspace 1 \t2. USD"
  choice = gets.chomp

  case choice
  when "1" #Choose workspace 1
      
      @workspace = "Workspace 1"
      puts "Enter Project:"
      
      @project = gets.chomp
      puts "Enter your file name:#csv"
      
      file_name = gets.chomp
      puts "Enter command : 1. Create\t2. Update\t3. Read"
      command = gets.chomp
      
      case command
      when "1" #create
        read_file(file_name)
        puts @rows
        
        puts "Workspace #{@workspace}"
        puts "Project #{@project}"
        puts "\n"
        
        release_crud = Release_CRUD.new(@workspace, @project)
        
        @iCount = 0 #@iCount = 0 or rows.length-1
     #   puts @rows[@iCount]
      #  puts @rows.length
        while @iCount < @rows.length
          result = release_crud.find_release(@rows[@iCount])
          if (result.length != 0)
            puts "Can't create , the same release exists!"
            puts "\n"
          else
            release_crud.create_release(@rows[@iCount])
          end

          @iCount += 1
        end

      when "2" #update
        read_file(file_name)
        puts @rows
        
        puts "Workspace #{@workspace}"
        puts "Project #{@project}"
        puts "\n"
        
        release_crud = Release_CRUD.new(@workspace, @project)
        
        @iCount = 0 #@iCount = 0 or rows.length-1
     #   puts @rows[@iCount]
      #  puts @rows.length
        while @iCount < @rows.length
          release_crud.update_release(@rows[@iCount])
          puts "\n"
          @iCount += 1
        end
        
      when "3" #read
        read_file(file_name)
        puts @rows
        
        puts "Workspace #{@workspace}"
        puts "Project #{@project}"
        puts "\n"
        
        release_crud = Release_CRUD.new(@workspace, @project)
        
        @iCount = 0 #@iCount = 0 or rows.length-1
     #   puts @rows[@iCount]
      #  puts @rows.length
        while @iCount < @rows.length
          result = release_crud.find_release(@rows[@iCount])
          @iCount += 1
          puts "\n"
        end
      end
          
    when "2" #choose USD
      @workspace = "USD"
      puts "Enter Project:"
      
      @project = gets.chomp
      puts "Enter your file name:#csv"
      
      file_name = gets.chomp
      puts "Enter command : 1. Create\t2. Update\t3. Read"
      command = gets.chomp
      
      case command
      when "1" #create
        read_file(file_name)
        puts @rows
        
        puts "Workspace #{@workspace}"
        puts "Project #{@project}"
        puts "\n"
        
        release_crud = Release_CRUD.new(@workspace, @project)
        
        @iCount = 0 #@iCount = 0 or rows.length-1
     #   puts @rows[@iCount]
      #  puts @rows.length
        while @iCount < @rows.length
          result = release_crud.find_release(@rows[@iCount])
          if (result.length != 0)
            puts "Can't create , the same release exists!"
            puts "\n"
          else
            release_crud.create_release(@rows[@iCount])
          end

          @iCount += 1
        end

      when "2" #update
        read_file(file_name)
        puts @rows
        
        puts "Workspace #{@workspace}"
        puts "Project #{@project}"
        puts "\n"
        
        release_crud = Release_CRUD.new(@workspace, @project)
        
        @iCount = 0 #@iCount = 0 or rows.length-1
     #   puts @rows[@iCount]
      #  puts @rows.length
        while @iCount < @rows.length
          release_crud.update_release(@rows[@iCount])
          puts "\n"
          @iCount += 1
        end
        
      when "3" #read
        read_file(file_name)
        puts @rows
        
        puts "Workspace #{@workspace}"
        puts "Project #{@project}"
        puts "\n"
        
        release_crud = Release_CRUD.new(@workspace, @project)
        
        @iCount = 0 #@iCount = 0 or rows.length-1
     #   puts @rows[@iCount]
      #  puts @rows.length
        while @iCount < @rows.length
          result = release_crud.find_release(@rows[@iCount])
          @iCount += 1
          puts "\n"
        end
      end
  end

end


def read_file(file_name)
  input = CSV.read(file_name)
  header = input.first
  #puts header
  @rows = []
  (1...input.size).each { |i| @rows << CSV::Row.new(header, input[i]) }
end

start