#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <poll.h>
#include <errno.h>

//IR Includes
#include "libsonyir.h"
#include "commands.h"

void printUsage(char *name){

    printf("Usage : %s <options> <keyfile.bin>\n", name);
    printf("-l : learn the ir code and store in key.bin\n");
    printf("-s : send the if code stored in key.bin\n");
}


int main(int argc, char *argv[] ){

    int mode = 0;
    if ( argc != 3 ) /* argc should be 2 for correct execution */
    {
        printUsage(argv[0]);
        return -1;
    }

    if (strcmp(argv[1],"-l") == 0){
        mode = 0;
    } else if (strcmp(argv[1],"-s") == 0) {
        mode = 1;
    } else {
        printUsage(argv[0]);
        return -1;
    }
    
    
    char filename[] = "key.bin";
    IRpowerOn(1);

    if (IRserialOpen()<0){
        printf("%s E: Error getting serial device\n", __func__);
    }

    IRkickStart();
    sleep(1);
    if (mode == 0)
       IRlearnKeyToFile(argv[2]);
    else
       IRsendKeyFromFile(argv[2]);
    sleep(2);
    printf("\n");
    IRserialClose();
    IRpowerOn(0);

    return 1;
}
