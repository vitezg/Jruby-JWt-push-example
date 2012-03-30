#Java classes will be used here too
require 'java'

import "eu.webtoolkit.jwt.WContainerWidget"
import "eu.webtoolkit.jwt.WBreak"
import "eu.webtoolkit.jwt.WApplication"
import "eu.webtoolkit.jwt.WLineEdit"
import "eu.webtoolkit.jwt.WText"
import "eu.webtoolkit.jwt.WLength"

#use the parts shown previously
require "ChatServer"
require "LoginDialog"

#subclass the WApplication class
class ChatApp < WApplication
	def initialize(env)
		super
		
		#the enableUpdates call is necessary to enable
		#push updates
		enableUpdates
		setTitle("Chat!")
		
		#set up the widgets: a container widget to hold
		#the chat lines, with a height of 480 pixels,
		#and scroll bar displayed only if the text overflows
		@chatcontainer=WContainerWidget.new getRoot
		@chatcontainer.setHeight(WLength.new 480)
		@chatcontainer.setOverflow(WContainerWidget::Overflow::OverflowAuto)

		#some line break and text
		WBreak.new getRoot
		WText.new "Your message:",getRoot
		
		#chat input line, with 30 character width
		@chatinput=WLineEdit.new getRoot
		@chatinput.setTextSize 30
		@chatinput.setFocus
		
		#on enter press, display the text in the user's own session
		#with addstring, and push the text out to every other session
		#with pushstring
		@chatinput.enterPressed.add_listener(self) do 
			addstring("me: "+@chatinput.getText)
			$chatserver.sessionsbutthis(self).each {|i|
				i.pushstring @name+": "+@chatinput.getText
			}
			@chatinput.setText ""

		end
		
		#register this session with the chat server,
		#and show the login dialog
		$chatserver.addsession self
		LoginDialog.new(self).show
	end
	
	#set the focus on the input line; called from LoginDialog
	def setfocus
		@chatinput.setFocus
	end
	
	#JWt calls the destroy function when the window for this session is
	#closed. So notify the other users, and unregister the name and the session.
	def destroy
		$chatserver.sessionsbutthis(self).each {|i|
			i.pushstring "Logged out:" + @name
		}
		$chatserver.releasesession self
		$chatserver.releasename @name
	end
	
	#the LoginDialog calls this after successful name registration
	#handy place to push a "Logged in" message to other users
	def name=(n)
		@name=n
		$chatserver.sessionsbutthis(self).each {|i|
			i.pushstring "Logged in:" + @name 
		}
		addstring "Logged in:" + @name
	end

	#This function is called from other sessions to push a line to this
	#chat window
	#This is where the "server push" happens.
	def pushstring(s)
	
		#take the update lock to serialize the requests
		lock = getUpdateLock
		begin
			
			#simply call addstring to actually display the text
			addstring(s)
			
			#call triggerUpdate to push the changes to the browser
			triggerUpdate
		rescue
		end
		
		#do not forget to release the lock!
		lock.release
	end

	private
	
	#adds a string to the chat container
	def addstring(s)
	
		#adds a string to the chat container
		w=WText.new s,@chatcontainer
	
		#set inline to false, so every string appears
		#on a new line
		w.setInline false
		
		#remove a line if already more than 100 are displayed
		if @chatcontainer.getCount > 100
			@chatcontainer.getChildren.remove 0
		end
		
		#push some JavaScript to the client side, to make the
		# chat container scroll to the bottom
		#originally from the JWt SimpleChat example
		doJavaScript(@chatcontainer.getJsRef+".scrollTop += "+@chatcontainer.getJsRef() + ".scrollHeight;")
	end
end


