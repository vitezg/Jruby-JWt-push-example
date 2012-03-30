#"thread" is required for the mutexes
require "thread"
class ChatServer
	def initialize
		
		#we will keep track of the names
		#and sessions in arrays, and protect
		#them from parallel updates with mutexes
		@names=Array.new
		@sessions=Array.new
		@sessionmutex=Mutex.new
		@namemutex=Mutex.new
	end
	
	#the chat application will use this function
	#to determine which sessions to broadcast to
	def sessionsbutthis(ses)
		@sessionmutex.synchronize{  
			copy=Array.new @sessions
			copy.delete ses
			copy
		}
	end
	
	#functions to register and remove sessions
	def releasesession(ses)
		@sessionmutex.synchronize{
			@sessions.delete ses
		}
	end	
	def addsession(ses)
		 @sessionmutex.synchronize{
		 	@sessions << ses
		 }  
	end

	#function to reserve a name, returns true
	#if the name was not already taken
	def reservename(name)
		@namemutex.synchronize{
		if @names.include? name
			false
		else
			@names << name
			true
		end
		}
	end

	#function to suggest a name, it will be called
	#upon login, if the name requested by the user
	#is already taken
	def suggestname(name)
		@namemutex.synchronize{
			i=1
			while @names.include?(name+i.to_s)
		 		i+=1
			end
			name+i.to_s
		}
	end

	#unregister the name
	def releasename(name)
		@namemutex.synchronize{
			@names.delete name
		}
	end
end

#global chatserver object, to keep track of the things
$chatserver=ChatServer.new
