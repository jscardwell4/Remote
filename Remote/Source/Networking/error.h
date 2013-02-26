//
// error.h
// Networking
//
// Created by Jason Cardwell on 9/21/12.
// Copyright (c) 2012 Jason Cardwell. All rights reserved.
//

#ifndef Networking_error_h
#define Networking_error_h

void err_sys(const char * fmt, ...);
void err_dump(const char * fmt, ...);
void err_ret(const char * fmt, ...);
void err_msg(const char * fmt, ...);
void err_quit(const char * fmt, ...);
#endif /* ifndef Networking_error_h */
