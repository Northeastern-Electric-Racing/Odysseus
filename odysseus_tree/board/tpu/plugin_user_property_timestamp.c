#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


#include "nanomq/plugin.h"

// upstream calls this function and accesses property from the data variable, then frees the properties after message is sent
int cb(void *data)
{
	char **property = data;
	if (property != NULL) {
		
		// key of ts, add 1 bc termination byte
		property[0] = malloc(strlen("ts") + 1);
		strcpy(property[0], "ts");
		
		
		// the below is used to get the time in miliseconds, required since there is no api for milisecond precision 
		struct timeval tv;
  
		gettimeofday(&tv, NULL);
  
		// do the math to get the miliseconds since unix epoch
		unsigned long long millisecondsSinceEpoch =
			(unsigned long long)(tv.tv_sec) * 1000 +
			(unsigned long long)(tv.tv_usec) / 1000;
			
		// currently the time is using 13 characters, so 30 should be enough
 		char str[30]; 
 		// convert the epoch time to a char arr
		sprintf(str, "%llu", millisecondsSinceEpoch);
 		
 		// value of the time, add 1 bc termination byte
 		property[1] = malloc(strlen(str)+1);
 		strcpy(property[1], str);
	}

	return 0;
}

int nano_plugin_init()
{
	plugin_hook_register(HOOK_USER_PROPERTY, cb);
	return 0;
}
