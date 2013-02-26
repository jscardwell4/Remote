//
// helper_functions.h
// Networking
//
// Created by Jason Cardwell on 9/21/12.
// Copyright (c) 2012 Jason Cardwell. All rights reserved.
//

#ifndef Networking_helper_functions_h
#define Networking_helper_functions_h

int  family_to_level(int family);
int  Family_to_level(int family);
int  mcast_join(int sockfd, const struct sockaddr * grp, socklen_t grplen, const char * ifname, u_int ifindex);
void Mcast_join(int sockfd, const struct sockaddr * grp, socklen_t grplen, const char * ifname, u_int ifindex);
int  mcast_join_source_group(int sockfd, const struct sockaddr * src, socklen_t srclen, const struct sockaddr * grp, socklen_t grplen, const char * ifname, u_int ifindex);
void Mcast_join_source_group(int sockfd, const struct sockaddr * src, socklen_t srclen, const struct sockaddr * grp, socklen_t grplen, const char * ifname, u_int ifindex);
int  udp_client(const char * host, const char * serv, struct sockaddr ** saptr, socklen_t * lenp);
int  Udp_client(const char * host, const char * serv, struct sockaddr ** saptr, socklen_t * lenptr);
int  Accept(int fd, struct sockaddr * sa, socklen_t * salenptr);
void Bind(int fd, const struct sockaddr * sa, socklen_t salen);
void Connect(int fd, const struct sockaddr * sa, socklen_t salen);
void Getpeername(int fd, struct sockaddr * sa, socklen_t * salenptr);
void Getsockname(int fd, struct sockaddr * sa, socklen_t * salenptr);
void Getsockopt(int fd, int level, int optname, void * optval, socklen_t * optlenptr);
int  Inet6_rth_space(int type, int segments);

void * Inet6_rth_init(void * rthbuf, socklen_t rthlen, int type, int segments);

void Inet6_rth_add(void * rthbuf, const struct in6_addr * addr);
void Inet6_rth_reverse(const void * in, void * out);
int  Inet6_rth_segments(const void * rthbuf);

struct in6_addr * Inet6_rth_getaddr(const void * rthbuf, int idx);

int     Kqueue(void);
int     Kevent(int kq, const struct kevent * changelist, int nchanges, struct kevent * eventlist, int nevents, const struct timespec * timeout);
void    Listen(int fd, int backlog);
int     Poll(struct pollfd * fdarray, unsigned int nfds, int timeout);
ssize_t Recv(int fd, void * ptr, size_t nbytes, int flags);
ssize_t Recvfrom(int fd, void * ptr, size_t nbytes, int flags, struct sockaddr * sa, socklen_t * salenptr);
ssize_t Recvmsg(int fd, struct msghdr * msg, int flags);
int     Select(int nfds, fd_set * readfds, fd_set * writefds, fd_set * exceptfds, struct timeval * timeout);
void    Send(int fd, const void * ptr, size_t nbytes, int flags);
void    Sendto(int fd, const void * ptr, size_t nbytes, int flags, const struct sockaddr * sa, socklen_t salen);
void    Sendmsg(int fd, const struct msghdr * msg, int flags);
void    Setsockopt(int fd, int level, int optname, const void * optval, socklen_t optlen);
void    Shutdown(int fd, int how);
int     Sockatmark(int fd);
int     Socket(int family, int type, int protocol);
void    Socketpair(int family, int type, int protocol, int * fd);

void * Malloc(size_t size);
char * sock_ntop(const struct sockaddr * sa, socklen_t salen);
char * Sock_ntop(const struct sockaddr * sa, socklen_t salen);

void loop(int sockfd, socklen_t salen);
int  tcp_connect(const char * host, const char * serv);
int  Tcp_connect(const char * host, const char * serv);
#endif /* ifndef Networking_helper_functions_h */
