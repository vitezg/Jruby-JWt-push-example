require "java"

#import the neccessary Java classes
import "eu.webtoolkit.jwt.WDialog"
import "eu.webtoolkit.jwt.WLineEdit"
import "eu.webtoolkit.jwt.WPushButton"
import "eu.webtoolkit.jwt.WBreak"
import "eu.webtoolkit.jwt.WText"

#the LoginDialog will use the ChatServer for name handling
require "ChatServer"

#the LoginDialog is subclassed from the WDialog class
class LoginDialog < WDialog
	def initialize(app)
	
		#save the ChatApp object for later
		@app=app
		title="Please select a screen name."
		super title
		
		#with setModal true other controls on the screen are disabled,
		#so the user is forced to enter a name first
		setModal true
		setClosable false
		
		#add some text, a line edit, button
		#and some more text to the dialog
		#the last line will be used for feedback
		WText.new "&nbsp;<br/>Your screen name:", getContents
		@edit=WLineEdit.new getContents
		@edit.setFocus
		@okbutton=WPushButton.new "OK", getContents
		WBreak.new getContents
		@message=WText.new "&nbsp;", getContents
		
		#now wire up the enterPressed event on the lineEdit
		#and the button clicked event to call handlelogin
		@edit.enterPressed.add_listener(self) do
			handlelogin
		end
		@okbutton.clicked.add_listener(self) do
			handlelogin
		end
	end
	
	#this function will try to reserve the requested name,
	#and either accept it, or display a suggestion
	def handlelogin
		if $chatserver.reservename @edit.getText
			
			#the name was not yet taken, so we notify the
			#ChatApp object of the name
			@app.name= @edit.getText	
			
			#accept makes the dialog quit
			accept()
			
			#to make things simpler for the user, we set the
			#focus on the chat input WLineEdit
			@app.setfocus
		else
			
			#well, the requested name was already taken
			#so suggest a new one, and set it in the WLineEdit, too
			suggested=$chatserver.suggestname @edit.getText
			@message.setText "sorry, that name is taken, but " +suggested+ " is free."
			@edit.setText suggested
			
		end

	
	
	end
end
		
