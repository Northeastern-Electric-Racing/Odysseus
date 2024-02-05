## Base station mosquitto setup

All of the steps should be done in the ssh console of the base station, with IP addr `192.168.100.1`.
1. Clone repo
2. cd to this directory
3. run the below command.  note that the path to the moquitto.conf in this directory **must be absolute**.

`docker run --restart=always -it -p 1883:1883 -p 9001:9001 -v /path/to/mosquitto.conf:/mosquitto/config/mosquitto.conf -v /mosquitto/data -v /mosquitto/log -d eclipse-mosquitto`


### Tips and tricks

To get logs when mosquitto is running:

`docker ps`  
Use the corresponding name in the NAMES column for eclipse-mosquitto row.
`docker exec -it <name> sh`  
Cat the file:  
`cat ./mosquitto/log/mosquitto.log`
