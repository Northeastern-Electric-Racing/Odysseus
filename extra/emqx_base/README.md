## EMQX Base Station

Clone repo and cd to this directory.  

run with:  
`docker run -d --restart=always --name emqx -p 18083:18083 -p 1883:1883 -p 14567:14567/udp -v ./emqx.conf:/opt/emqx/etc/emqx.conf -v./listeners.quic.conf:/opt/emqx/etc/listeners.quic.conf -v./listeners.tcp.conf:/opt/emqx/etc/listeners.tcp.conf emqx:5.5.0`
