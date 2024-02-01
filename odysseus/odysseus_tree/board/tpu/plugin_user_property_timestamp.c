#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>


#include "nanomq/plugin.h"

/*
 * How to compile:
 * gcc -I../ -fPIC -shared plugin_user_property.c -o plugin_user_property.so
 */


int cb(void *data)
{
	char **property = data;
	if (property != NULL) {
		
		// key of ts, add 1 bc termination byte
		property[0] = malloc(strlen("ts") + 1);
		strcpy(property[0], "ts");
		
		struct timeval tv;
  
		gettimeofday(&tv, NULL);
  
		unsigned long long millisecondsSinceEpoch =
			(unsigned long long)(tv.tv_sec) * 1000 +
			(unsigned long long)(tv.tv_usec) / 1000;
			
		// currently the time is using 13 characters, so 30 should be enough
 		char str[30]; 
 		// convert the epoch time to a char arr
		sprintf(str, "%llu", millisecondsSinceEpoch);
// 		
// 		// value of the time, add 1 bc termination byte
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
