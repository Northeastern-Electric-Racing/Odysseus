## EMQX Base Station

Clone repo and cd to this directory.  


run with (note: absolute paths must be used):  
`docker run -d --restart=always --name emqx -p 18083:18083 -p 1883:1883 -p 14567:14567/udp -v /path/to/emqx.conf:/opt/emqx/etc/emqx.conf -v /path/to/listeners.quic.conf:/opt/emqx/etc/listeners.quic.conf -v /path/to/listeners.tcp.conf:/opt/emqx/etc/listeners.tcp.conf emqx:5.5.0`
