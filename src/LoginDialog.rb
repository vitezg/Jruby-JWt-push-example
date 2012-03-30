require "java"


import "eu.webtoolkit.jwt.WDialog"
import "eu.webtoolkit.jwt.WLineEdit"
import "eu.webtoolkit.jwt.WPushButton"
import "eu.webtoolkit.jwt.WBreak"
import "eu.webtoolkit.jwt.WText"

require "ChatServer"


class LoginDialog < WDialog
	def initialize(app)
		@app=app
		title="Please select a screen name."
		super title
		setModal true
		setClosable false
		WText.new "&nbsp;<br/>Your screen name:", getContents
		@edit=WLineEdit.new getContents
		@edit.setFocus
		@okbutton=WPushButton.new "OK", getContents
		WBreak.new getContents
		@message=WText.new "&nbsp;", getContents
		@edit.enterPressed.add_listener(self) do
			handlelogin
		end
		@okbutton.clicked.add_listener(self) do
			handlelogin
		end
	end
	def handlelogin
		if $chatserver.reservename @edit.getText
			@app.name= @edit.getText	
			accept()
			#setHidden true
			@app.setfocus
			#@app.@chatinput.setFocus
		else
			suggested=$chatserver.suggestname @edit.getText
			@message.setText "sorry, that name is taken, but " +suggested+ " is free."
			@edit.setText suggested
			
		end

	
	
	end
end
		
