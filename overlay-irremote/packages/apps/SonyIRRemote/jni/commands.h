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


#ifndef IRCMD_HDDR
#define IRCMD_HDDR

//structure of the version command
typedef struct {

    char cmdlen; //length of the cmd
    char cmd ; //command 0x11 for version/status

} cmdVersion;


//structure of the key command
typedef struct {

    char cmdlen; //length of the the cmd (excluding magic,blanl & cmdlen)
    char cmd ; //cmd 0x01 / 1 for send key
    char devid[2]; //two byte data for device ID
    char cmdkey; //key command
    char reserved[4]; //reserved for other (longer) commands

} cmdKey;


//structure of list supported keys command
typedef struct {

    char cmdlen; //length of the the cmd (excluding magic,blanl & cmdlen)
    char cmd ; //cmd 0x03 / 3 for list keys
    char devid[2]; //two byte data for device ID

} cmdListKeys;

typedef struct {

    char cmdlen; //length of the the cmd (excluding magic,blanl & cmdlen)
    char cmd ; //cmd 0x12 for leankeydata
    char leanid[2]; //id to learn the key to

} cmdGetKeyData;


typedef struct {

    char cmdlen; //length of the the cmd (excluding magic,blanl & cmdlen)
    char cmd ; //cmd 0x10 for sendkeydata
    char leanid[2]; //id to learn the key to
    char lerntcmd[255];

} cmdSendKeyData;

#endif
