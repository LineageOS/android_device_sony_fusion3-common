/*
 *
 * This file is part of libsonyir
 * Copyright (c) 2013, Shane Francis, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 *
 */

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
#include <stdlib.h>

//IR Includes
#include "libsonyir.h"
#include "commands.h"

#define LOG_TAG "libsonyir"

#ifdef ANDROID

#include <android/log.h>  
#define LOGI(a, args...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, a, ##args)
#define LOGD(a, args...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, a, ##args)
#define LOGE(a, args...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, a, ##args)

#else

#define LOGI(a, args...) printf(a, ##args)
#define LOGD(a, args...) printf(a, ##args)
#define LOGE(a, args...) printf(a, ##args)

#endif

#define IRPOWERNODE "/sys/devices/platform/ir_remote_control/enable"
#define IRDEVICE "/dev/ttyHSL2"


static int fd = 0;
static struct termios toptions;
static int sleeptime = 10000;

int IRsendcmd(void *cmd, int len){

    LOGI("%s : CALLED\n", __func__);

    struct pollfd polldata;
    polldata.fd = fd;
    polldata.events = 4;

    poll(&polldata, 1u, 1000);

    //wake up the device ready for the transmittion of the command
    char zero = '\0';
    write(fd,&zero,1u);
    usleep(sleeptime);

    poll(&polldata, 1u, 1000);
    //send the command
    int status = write(fd, cmd, len); //write the data
    usleep(sleeptime); //make sure the IR device has time to process

    return status;
}

//Powers on the IR chip by writing to the correct device node
int IRpowerOn(int state){

    LOGI("%s : CALLED\n", __func__);

    errno = 0;
    int powerctl = open(IRPOWERNODE, O_WRONLY);

    if (powerctl < 0){
        LOGE("%s : Error opaning power node %s error : %s\n", __func__, IRPOWERNODE , strerror(errno));
    }

    char ctl;
    if (state)
        ctl = '1';
    else
        ctl = '0';

    write(powerctl, &ctl ,1);
    close(powerctl);
    sleep(1);

    return 1;
}

//Open the serial device and set the correct serial settings
int IRserialOpen(){

    LOGI("%s : CALLED\n", __func__);

    errno = 0;

    //open the device
    fd = open(IRDEVICE, O_RDWR | O_NOCTTY ); 
    if (fd <0){
        LOGE("%s : Error opaning serial device %s error : %s\n", __func__, IRDEVICE, strerror(errno));
    }

    //get the current otions
    tcgetattr(fd, &toptions);

    //set the options (dumped from monitoring stock behavior) will need to change these to flags
    toptions.c_iflag = 4u;
    toptions.c_oflag = 0u;
    toptions.c_cflag = 2147485886u;
    toptions.c_lflag = 0u;
    toptions.c_line = 0u;

    //set the correct speed for the device (19200)
    cfsetispeed(&toptions, B19200);
    cfsetispeed(&toptions, B19200);

    unsigned int i = 0;
    for (i = 0; i < sizeof(toptions.c_cc); i++){
        toptions.c_cc[i] = 0u;
    }

    toptions.c_cc[VMIN] = 1u;
    toptions.c_cc[VTIME] = 50;

    //set the options 

    int state = tcsetattr(fd, TCSANOW, &toptions);
    if( state < 0) {
        LOGE("%s E: Error setting serial attributes\n", __func__);
    }

    //sleep and flush the buffers ready for accepting communication/commands
    usleep(sleeptime);
    tcflush(fd,TCIOFLUSH);
    usleep(sleeptime);

    return 1;

}

//close the serial device
int IRserialClose(){

    LOGI("%s : CALLED\n", __func__);

    //close serial device
    int ret = close(fd);
    return ret;
}

//requests the raw data for a IR key (being sent from another IR source)
int IRlearnKeyData(char **data){

    //flush the serial buffer and sleep to ensure no data is their
    tcflush(fd,TCIOFLUSH);
    usleep(sleeptime);

    LOGI("%s : CALLED\n", __func__);

    cmdGetKeyData learnkey;

    struct pollfd polldata;
    polldata.fd = fd;
    polldata.events = 4;

    //initialise the struct
    memset(&learnkey,'\0',sizeof(learnkey));
    learnkey.cmdlen = 0x03; //this cmd is of one byte long
    learnkey.cmd = 0x12; //0x11 is the verison cmd
    learnkey.leanid[1] = 0x01; //Learn the key to slot 1

    char magic[] = "\x40\x41\x42\x43";
    
    int status = IRsendcmd(&magic, 4); //send the "magic" data
    status = IRsendcmd(&learnkey, sizeof(learnkey)); //send the "key raw key command"
    LOGI("%s : Write status %d\n",__func__,status);

    //usleep(50000);

    //get the response length
    int response_len = 0; 
    read(fd, &response_len, 1); //the first byte of the respone is the length of the response

    *data = malloc(response_len * sizeof(char));
    
    char *localdata = *data;
    memset(localdata,'\0', response_len * sizeof(char));

    LOGI("%s : response len %d\n",__func__,response_len);

    int count = 0;
    //read off the length of the response
    while(count < response_len){    
        poll(&polldata, 1u, 1000);
    	status = read(fd, &localdata[count], 1);
        count++;
    }   

    return response_len;

}


int IRlearnKeyToFile(const char *filename){

    LOGI("%s : CALLED\n", __func__);


    char *keydata;
    int length;

    length = IRlearnKeyData(&keydata);

    int i =0;
    for(i=0; i<length; i++){
        LOGI("%s : response data 0x%X\n",__func__,keydata[i]);
    }

    int outfile = open(filename, O_RDWR | O_CREAT, 0666);

    LOGI("%s : test! %d\n",__func__, length);
    int status = write(outfile, &length, 1);
    status = write(outfile, keydata, length);

    close(outfile);
    free(keydata);
    return length;

}

int IRsendKeyFromFile(const char *filename){

    
    int infile = open(filename, O_RDONLY);

    if (infile < 0){
        LOGE("%s : Could Not Open Key : %s\n", __func__, filename);
        return -1;
    }


    unsigned int keylen = 0;

    read(infile, &keylen, 1);

    char keydata[keylen];

    read(infile, &keydata , keylen);
    close(infile);

    LOGI("%s : Sending Key Of Length %d\n", __func__, keylen);
    int status = IRsendRawKey(keydata, keylen);
    return status;


}

int IRsendRawKey(char *data, int length){

    tcflush(fd,TCIOFLUSH);
    usleep(sleeptime);

    LOGI("%s : CALLED\n", __func__);

    cmdSendKeyData keySend;

    //initialise the struct
    memset(&keySend,'\0',sizeof(keySend));
    keySend.cmdlen = length + 3; //keylength + 3
    keySend.cmd = 0x10;
    keySend.leanid[1] = 0x01; //Learn the key to slot 1

    memcpy(keySend.lerntcmd, data, length);

    keySend.lerntcmd[0] = 0x10;


    char magic[] = "\x40\x41\x42\x43";
    
    int status = IRsendcmd(&magic, 4);
    status = IRsendcmd(&keySend, 4 + length);

    struct pollfd polldata;
    polldata.fd = fd;
    polldata.events = 4;

    poll(&polldata, 1u, 1000);

    //wake up the device ready for the transmittion of the command
    usleep(sleeptime*10);
    char zero = '\0';
    write(fd,&zero,1u);

    LOGI("%s : sent : %d",__func__,status);

    return status;
}


int IRkickStart(){

    tcflush(fd,TCIOFLUSH);
    usleep(sleeptime);

    LOGI("%s : CALLED\n", __func__);

    cmdVersion vers;
    memset(&vers,'\0',sizeof(vers));
    vers.cmdlen = 0x1;
    vers.cmd = 0x11;



    char magic[] = "\x40\x41\x42\x43";
    
    int status = IRsendcmd(&magic, 4);
    status = IRsendcmd(&vers, sizeof(vers));

    //get the response length
    int response_len = 0; 
    read(fd, &response_len, 1); //the first byte of the respone is the length of the response

    //create the storage for the response
    char response[response_len];
    //read off the length of the response
    status = read(fd, &response, response_len);
    LOGI("%s : Read response of size %d\n",__func__,status);

    return 1;
    

}



