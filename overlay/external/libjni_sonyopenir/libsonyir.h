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

int IRsendcmd(void *cmd, int len);
int IRpowerOn(int state);
int IRserialOpen();
int IRserialClose();
int IRlearnKeyToFile(const char *filename);
int IRsendKeyFromFile(const char *filename);
int IRsendRawKey(char *data, int length);
int IRlearnKeyData(char **data);
int IRkickStart();
