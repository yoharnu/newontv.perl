#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <regex.h>

#include "dllist.h"
#include "jrb.h"

Dllist newShows;

typedef struct {
	char* name;
	int id;
	char* network;
} show;

void usage(){
	printf("usage: newontv [listOfShows]\n");
	exit(1);
}

void* wgetThread(void* arg){
	char* file = (char*) arg;
	char* wget = malloc(sizeof(char) * (strlen(file) + strlen("wget -q ")));
	strcpy(wget, "wget -q ");
	strcat(wget, file);
	free(file);
	system(wget);
	free(wget);
	pthread_exit((void*) NULL);
}

void* showThread(void* arg){

	return NULL;
}

char*  makeReplacements(char* show){
	return show;
}

int main(int argc, char** argv){
	
	if(argc < 2)
		usage();

	pthread_t* id = malloc(sizeof(pthread_t));
	pthread_create(id, NULL, wgetThread, strdup("http://www.tvguide.com/new-tonight/80001"));

	newShows = new_dllist();

	char* filename = malloc(sizeof(char) * strlen(argv[1]));
	strcpy(filename, argv[1]);

	JRB shows = make_jrb();
	FILE* showFile = fopen(filename, "r");
	char* buf = malloc(sizeof(char) * 200);
	while(!feof(showFile)){
		fgets(buf, 200, showFile);
		buf[strlen(buf)-1] = '\0';
		if(!feof(showFile)){
			jrb_insert_str(shows, buf, JNULL);
		}
	}
	free(buf);
	close(showFile);

	pthread_join(*id, NULL);

	showFile = fopen("80001", "r");
	buf = malloc(sizeof(char) * 200);
	regex_t* reg = malloc(sizeof(regex_t));
	Dllist tids = new_dllist();
	while(!feof(showFile)){
		regcomp(reg, "SHOW LINK, SHOW TITLE", 0);
		fgets(buf, 200, showFile);
		if(!feof(showFile)){
			if(!regexec(reg, buf, 0, NULL, 0)){
				fgets(buf, 200, showFile);
				fgets(buf, 200, showFile);
				regcomp(reg, ">.*<", 0);
				regmatch_t matchptr[1];
				if(!regexec(reg, buf, 1, matchptr, 0)){
					buf[matchptr[0].rm_eo-1] = '\0';
					char* showName = malloc(sizeof(char)*(matchptr[0].rm_eo - matchptr[0].rm_so));
					strcpy(showName, buf+matchptr[0].rm_so+1);
					showName = makeReplacements(showName);
					//printf("%s\n", showName);
					JRB node;
					jrb_traverse(node, shows){
						printf("%s\n", node->key.v);
					}
					if(jrb_find_str(shows, showName) != NULL){
						//printf("%s\n", showName);
						pthread_create(id, NULL, showThread, strdup(showName));
						dll_append(tids, new_jval_v(id));
					}
				}
			}
		}
	}
	free(buf);
	close(showFile);

	system("rm -f 80001.*");



	return 0;
}
