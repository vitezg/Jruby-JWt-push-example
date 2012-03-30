require "thread"
class ChatServer
	def initialize
		@names=Array.new
		@sessions=Array.new
		@sessionmutex=Mutex.new
		@namemutex=Mutex.new
	end
	
	def sessionsbutthis(ses)
		@sessionmutex.synchronize{  
			copy=Array.new @sessions
			copy.delete ses
			copy
		}
	end
	
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

	def suggestname(name)
		@namemutex.synchronize{
			i=1
			while @names.include?(name+i.to_s)
		 		i+=1
			end
			name+i.to_s
		}
	end

	def releasename(name)
		@namemutex.synchronize{
			@names.delete name
		}
	end
end
		
$chatserver=ChatServer.new
