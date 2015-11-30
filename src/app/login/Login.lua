local Login = class("Login")


function Login:ctor()
	
   	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

end



return Login