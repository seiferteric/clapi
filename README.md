clapi
=====

Hokey little rack based api server


This will listen on the desired port and execute a script in the desired directory with the name of the method.

For example, if you send: GET /users

It will look for a script in the root/users/GET and execute it if it exists, or return 404 if it does not. 

The return code of the script is the returned status code while the STDOUT will be treated as the message content. 
The first lines of STDOUT up until the first newline will be treated as HTTP headers in this form: "Content-Type text/html". 
After the first newline will be the body.


DISCLAIMER:
Don't use this! Totally unsafe! Not a real project. It Can and will execute arbitrary code on your system (for now :)
