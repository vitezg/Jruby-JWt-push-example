#this really needs to get abstracted out by now
require "java"

import "eu.webtoolkit.jwt.WtServlet"

import "org.apache.catalina.startup.Tomcat"
import "org.apache.catalina.connector.Connector"

require "ChatApp"               

class MyServlet < WtServlet
  def createApplication(env)
	ChatApp.new env
  end
end

tomcat=Tomcat.new
tomcat.setBaseDir("/tmp")
con=Connector.new("org.apache.coyote.http11.Http11NioProtocol")

con.setPort(8888)
tomcat.getService().addConnector(con)
tomcat.setConnector(con)

ctx=tomcat.addContext("/","/tmp")
tomcat.addServlet("/","jwt example",MyServlet.new)
ctx.addServletMapping("/*", "jwt example")
ctx.addApplicationListener("eu.webtoolkit.jwt.ServletInit")
tomcat.start
tomcat.getServer().await
