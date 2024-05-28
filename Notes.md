# IP RESTRICTION BYPASS
"X-Forwarded-For" http header with value of needed ip address<br>
IP address spaces reserved for private networks<br>
10.0.0.0        -   10.255.255.255  (10/8 prefix)<br>
172.16.0.0      -   172.31.255.255  (172.16/12 prefix)<br>
192.168.0.0     -   192.168.255.255 (192.168/16 prefix)<br>
# OPEN REDIRECT
Simply try to change the domain<br>
Example: ?redirect=https://example.com --> ?redirect=https://evil.com<br>
Bypass the filter when protocol is blacklisted using //<br>
Example: ?redirect=https://example.com --> ?redirect=//evil.com<br>
Bypass the filter when double slash is blacklisted using \\<br>
Example: ?redirect=https://example.com --> ?redirect=\evil.com<br>
Bypass the filter when double slash is blacklisted using http: or https:<br>
Example: ?redirect=https://example.com --> ?redirect=https:example.com<br>
Bypass the filter using %40<br>
Example: ?redirect=example.com --> ?redirect=example.com%40evil.com<br>
Bypass the filter if it only checks for domain name<br>
Example: ?redirect=example.com --> ?redirect=example.comevil.com<br>
Bypass the filter if it only checks for domain name using a dot %2e<br>
Example: ?redirect=example.com --> ?redirect=example.com%2eevil.com<br>
Bypass the filter if it only checks for domain name using a query/question mark ?<br>
Example: ?redirect=example.com --> ?redirect=evil.com?example.com<br>
Bypass the filter if it only checks for domain name using a hash %23<br>
Example: ?redirect=example.com --> ?redirect=evil.com%23example.com<br>
Bypass the filter using a ° symbol<br>
Example: ?redirect=example.com --> ?redirect=example.com/°evil.com<br>
Bypass the filter using a url encoded Chinese dot %E3%80%82<br>
Example: ?redirect=example.com --> ?redirect=evil.com%E3%80%82%23example.com<br>
Bypass the filter if it only allows you to control the path using a nullbyte %0d or %0a<br>
Example: ?redirect=/ --> ?redirect=/%0d/evil.com<br>
# HASH REDIRECTION
some sites may use hash to identify if redirect link is valid
http://sample.com/?url=https://valid_redirect.com&hash=encrypted_hash_value
just generate hash for needed website
# SOCKETS
Do not forget to emulate user input when sending data(add "\n")<br>
# REQUESTS
Do not forget to create session for cookie saving<br>
# BUFFER OVERFLOW
check to which encoding you convert + don't forget about endians<br>
# ASSEMBLY
DO NOT FORGET ABOUT CALLING CONVENTIONS AND SHADOW SPACE<br>
RAX - function return value<br>
RCX - first function parameter<br>
RDX - second function parameter<br>
R8  - third function parameter<br>
R9  - forth function parameter<br>
fifth+ functions parameters are PUSHed onto stack<br>
command line arguments:<br>
argc in rcx<br>
argv in rdx(rdx+8 for second,rdx+16 for third etc)<br>
# GRAPHICS
To render something into imgui image - 
1)Create a framebuffer and a texture to it
2)Bind framebuffer before draw calls, so everything gets rendered into fbo
3)Use texture ID to create imgui image
