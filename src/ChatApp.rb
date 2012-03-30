require 'java'

import "eu.webtoolkit.jwt.WContainerWidget"
import "eu.webtoolkit.jwt.WBreak"
import "eu.webtoolkit.jwt.WApplication"
import "eu.webtoolkit.jwt.WLineEdit"
import "eu.webtoolkit.jwt.WText"
import "eu.webtoolkit.jwt.WLength"
#import "eu.webtoolkit.jwt.WContainerWidget.Overflow.OverflowAuto"

#import "eu.webtoolkit.jwt.WtServlet"

require "ChatServer"
require "LoginDialog"

class ChatApp < WApplication
	def initialize(env)
		super
		enableUpdates
		setTitle("Chat!")
		@chatcontainer=WContainerWidget.new getRoot
		@chatcontainer.setHeight(WLength.new 480)
		@chatcontainer.setOverflow(WContainerWidget::Overflow::OverflowAuto)
		WBreak.new getRoot
		WText.new "Your message:",getRoot
		@chatinput=WLineEdit.new getRoot
		@chatinput.setTextSize 30
		@chatinput.setFocus
		@chatinput.enterPressed.add_listener(self) do 
			addstring("me: "+@chatinput.getText)
			$chatserver.sessionsbutthis(self).each {|i|
				i.pushstring @name+": "+@chatinput.getText
			}
			@chatinput.setText ""

		end
		$chatserver.addsession self
		LoginDialog.new(self).show
	end
	
	def setfocus
		@chatinput.setFocus
	end
	
	def destroy
		$chatserver.sessionsbutthis(self).each {|i|
			i.pushstring "Logged out:" + @name
		}
		$chatserver.releasesession self
		$chatserver.releasename @name
	end
	
	
	def name=(n)
		@name=n
		$chatserver.sessionsbutthis(self).each {|i|
			i.pushstring "Logged in:" + @name 
		}
		addstring "Logged in:" + @name
	end

	def pushstring(s)
		lock = getUpdateLock
		begin
			addstring(s)
			triggerUpdate
		rescue
		end
		lock.release
	
	end

	private
	def addstring(s)
		w=WText.new s,@chatcontainer
		w.setInline false
		if @chatcontainer.getCount > 100
			@chatcontainer.getChildren.remove 0
		end
		doJavaScript(@chatcontainer.getJsRef+".scrollTop += "+@chatcontainer.getJsRef() + ".scrollHeight;")
	end
end


