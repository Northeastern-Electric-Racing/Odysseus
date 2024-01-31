//
// Copyright 2024 NanoMQ Team, Inc. <jaylin@emqx.io>
//
// This software is supplied under the terms of the MIT License, a
// copy of which should be located in the distribution where this
// file was obtained (LICENSE.txt).  A copy of the license may also be
// found online at https://opensource.org/licenses/MIT.
//
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
		
		property[0] = malloc(strlen("ts") + 1);
		strcpy(property[0], "ts");
		
		struct timeval tv;
  
		gettimeofday(&tv, NULL);
  
		unsigned long long millisecondsSinceEpoch =
			(unsigned long long)(tv.tv_sec) * 1000 +
			(unsigned long long)(tv.tv_usec) / 1000;
			
		char str[sizeof(char)]; 
        sprintf(str, "%ld", millisecondsSinceEpoch);
		
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
