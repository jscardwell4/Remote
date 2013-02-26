//
// networking.h
// Networking
//
// Created by Jason Cardwell on 9/21/12.
// Copyright (c) 2012 Jason Cardwell. All rights reserved.
//

#ifndef Networking_networking_h
#define Networking_networking_h

#include <sys/types.h>	/* basic system data types */
#include <sys/socket.h>	/* basic socket definitions */
#include <sys/time.h>	/* timeval{} for select() */
#include <time.h>		/* timespec{} for pselect() */
#include <netinet/in.h>	/* sockaddr_in{} and other Internet defns */
#include <arpa/inet.h>	/* inet(3) functions */
#include <errno.h>
#include <fcntl.h>		/* for nonblocking */
#include <netdb.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>	/* for S_xxx file mode constants */
#include <sys/uio.h>	/* for iovec{} and readv/writev */
#include <unistd.h>
#include <sys/wait.h>
#include <sys/un.h>		/* for Unix domain sockets */
#include <sys/select.h>	/* for convenience */
#include <sys/param.h>	/* OpenBSD prereq for sysctl.h */
#include <sys/sysctl.h>
#include <poll.h>		/* for convenience */
#include <sys/event.h>	/* for kqueue */
#include <strings.h>	/* for convenience */

/* Three headers are normally needed for socket/file ioctl's:
 * <sys/ioctl.h>, <sys/filio.h>, and <sys/sockio.h>.
 */
#include <sys/ioctl.h>
#include <sys/filio.h>
#include <sys/sockio.h>
#include <pthread.h>
#include <net/if_dl.h>
#include <net/if.h>

// #include "helper_functions.h"
// #include "error.h"

#define SAP_VERSION       1
#define SAP_VERSION_MASK  0xe0000000
#define SAP_VERSION_SHIFT 29
#define SAP_IPV6          0x10000000
#define SAP_DELETE        0x04000000
#define SAP_ENCRYPTED     0x02000000
#define SAP_COMPRESSED    0x01000000
#define SAP_AUTHLEN_MASK  0x00ff0000
#define SAP_AUTHLEN_SHIFT 16
#define SAP_HASH_MASK     0x0000ffff

#define MAXLINE  4096  /* max text line length */
#define BUFFSIZE 8192  /* buffer size for reads and writes */
#endif /* ifndef Networking_networking_h */
