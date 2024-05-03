/*
 * Add an MQTT v5 user-property with key "ts" and value of timestamp in miliseconds since unix epoch.
 *
 *
 * Use in config with:
 *
 *   plugin /path/to/mosquitto_timestamp.so
 *
 */
#include "config.h"

#include <stdio.h>
#include <stdint.h>
#include <time.h>

#include "mosquitto_broker.h"
#include "mosquitto_plugin.h"
#include "mosquitto.h"
#include "mqtt_protocol.h"

static mosquitto_plugin_id_t *mosq_pid = NULL;

static int callback_message(int event, void *event_data, void *userdata)
{
	struct mosquitto_evt_message *ed = event_data;
	struct tm *ti;

	UNUSED(event);
	UNUSED(userdata);

	// # *** Below is new code for time conversion
	// the below is used to get the time in miliseconds, required since there is no api for milisecond precision 
	struct timeval tv;
  
	gettimeofday(&tv, NULL);
  
	// do the math to get the miliseconds since unix epoch
	uint64_t millisecondsSinceEpoch =
		(uint64_t)(tv.tv_sec) * 1000 +
		(uint64_t)(tv.tv_usec) / 1000;
	
	// currently the time is using 13 characters, so 30 should be enough
	char time_buf[30]; 
	// convert the epoch time to a char arr
	sprintf(time_buf, "%llu", millisecondsSinceEpoch);

	// # *** ^^^
	
	return mosquitto_property_add_string_pair(&ed->properties, MQTT_PROP_USER_PROPERTY, "ts", time_buf);
}

int mosquitto_plugin_version(int supported_version_count, const int *supported_versions)
{
	int i;

	for(i=0; i<supported_version_count; i++){
		if(supported_versions[i] == 5){
			return 5;
		}
	}
	return -1;
}

int mosquitto_plugin_init(mosquitto_plugin_id_t *identifier, void **user_data, struct mosquitto_opt *opts, int opt_count)
{
	UNUSED(user_data);
	UNUSED(opts);
	UNUSED(opt_count);

	mosq_pid = identifier;
	return mosquitto_callback_register(mosq_pid, MOSQ_EVT_MESSAGE, callback_message, NULL, NULL);
}

int mosquitto_plugin_cleanup(void *user_data, struct mosquitto_opt *opts, int opt_count)
{
	UNUSED(user_data);
	UNUSED(opts);
	UNUSED(opt_count);

	return mosquitto_callback_unregister(mosq_pid, MOSQ_EVT_MESSAGE, callback_message, NULL);
}
