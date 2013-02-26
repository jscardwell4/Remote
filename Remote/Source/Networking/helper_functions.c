#include "networking.h"

int family_to_level(int family) {
    switch (family) {
        case AF_INET :

            return IPPROTO_IP;

        case AF_INET6 :

            return IPPROTO_IPV6;

        default :

            return -1;
    }
}

int Family_to_level(int family) {
    int   rc;

    if ((rc = family_to_level(family)) < 0) fprintf(stderr, "family_to_level error: %d - %s", errno, strerror(errno));

    return (rc);
}

int mcast_join(int                     sockfd,
               const struct sockaddr * grp,
               socklen_t               grplen,
               const char            * ifname,
               u_int                   ifindex) {
// struct group_req req;
// if (ifindex > 0) {
// req.gr_interface = ifindex;
// } else if (ifname != NULL) {
// if ( (req.gr_interface = if_nametoindex(ifname)) == 0) {
// errno = ENXIO;	/* i/f name not found */
// return(-1);
// }
// } else
// req.gr_interface = 0;
// if (grplen > sizeof(req.gr_group)) {
// errno = EINVAL;
// return -1;
// }
// memcpy(&req.gr_group, grp, grplen);
// return (setsockopt(sockfd, family_to_level(grp->sa_family),
// MCAST_JOIN_GROUP, &req, sizeof(req)));
/* end mcast_join1 */

/* include mcast_join2 */
    switch (grp->sa_family) {
        case AF_INET : {
            struct ip_mreq   mreq;
            struct ifreq     ifreq;

            memcpy(&mreq.imr_multiaddr,
                   &((const struct sockaddr_in *)grp)->sin_addr,
                   sizeof(struct in_addr));

            if (ifindex > 0) {
                if (if_indextoname(ifindex, ifreq.ifr_name) == NULL) {
                    errno = ENXIO;  /* i/f index not found */
                    return (-1);
                }

                goto doioctl;
            } else if (ifname != NULL) {
                strncpy(ifreq.ifr_name, ifname, IFNAMSIZ);
doioctl:
                if (ioctl(sockfd, SIOCGIFADDR, &ifreq) < 0) return (-1);

                memcpy(&mreq.imr_interface,
                       &((struct sockaddr_in *)&ifreq.ifr_addr)->sin_addr,
                       sizeof(struct in_addr));
            } else
                mreq.imr_interface.s_addr = htonl(INADDR_ANY);


            return (setsockopt(sockfd, IPPROTO_IP, IP_ADD_MEMBERSHIP,
                               &mreq, sizeof(mreq)));
        }
/* end mcast_join2 */

/* include mcast_join3 */
        case AF_INET6 : {
            struct ipv6_mreq   mreq6;

                memcpy(&mreq6.ipv6mr_multiaddr,
                   &((const struct sockaddr_in6 *)grp)->sin6_addr,
                   sizeof(struct in6_addr));

            if (ifindex > 0)
                mreq6.ipv6mr_interface = ifindex;
            else if (ifname != NULL) {
                if ((mreq6.ipv6mr_interface = if_nametoindex(ifname)) == 0) {
                    errno = ENXIO;  /* i/f name not found */
                    return (-1);
                }
            } else
                mreq6.ipv6mr_interface = 0;


            return (setsockopt(sockfd, IPPROTO_IPV6, IPV6_JOIN_GROUP,
                               &mreq6, sizeof(mreq6)));
        }

        default :
            errno = EAFNOSUPPORT;

            return (-1);
    } /* switch */
}     /* mcast_join */

/* end mcast_join3 */

void Mcast_join(int                     sockfd,
                const struct sockaddr * grp,
                socklen_t               grplen,
                const char            * ifname,
                u_int                   ifindex) {
    if (mcast_join(sockfd, grp, grplen, ifname, ifindex) < 0) fprintf(stderr, "mcast_join error: %d - %s", errno, strerror(errno));
}

int mcast_join_source_group(int                     sockfd,
                            const struct sockaddr * src,
                            socklen_t               srclen,
                            const struct sockaddr * grp,
                            socklen_t               grplen,
                            const char            * ifname,
                            u_int                   ifindex) {
    struct group_source_req   req;

    if (ifindex > 0)
        req.gsr_interface = ifindex;
    else if (ifname != NULL) {
        if ((req.gsr_interface = if_nametoindex(ifname)) == 0) {
            errno = ENXIO;  /* i/f name not found */
            return (-1);
        }
    } else
        req.gsr_interface = 0;

    if (grplen > sizeof(req.gsr_group) || srclen > sizeof(req.gsr_source)) {
        errno = EINVAL;

        return -1;
    }

                memcpy(&req.gsr_group,  grp, grplen);
                memcpy(&req.gsr_source, src, srclen);

    return (setsockopt(sockfd, family_to_level(grp->sa_family),
                       MCAST_JOIN_SOURCE_GROUP, &req, sizeof(req)));
    switch (grp->sa_family) {
        case AF_INET : {
            struct ip_mreq_source   mreq;
            struct ifreq            ifreq;

                memcpy(&mreq.imr_multiaddr,
                   &((struct sockaddr_in *)grp)->sin_addr,
                   sizeof(struct in_addr));
                memcpy(&mreq.imr_sourceaddr,
                   &((struct sockaddr_in *)src)->sin_addr,
                   sizeof(struct in_addr));

            if (ifindex > 0) {
                if (if_indextoname(ifindex, ifreq.ifr_name) == NULL) {
                    errno = ENXIO;  /* i/f index not found */
                    return (-1);
                }

                goto doioctl;
            } else if (ifname != NULL) {
                strncpy(ifreq.ifr_name, ifname, IFNAMSIZ);
doioctl:
                if (ioctl(sockfd, SIOCGIFADDR, &ifreq) < 0) return (-1);

                memcpy(&mreq.imr_interface,
                       &((struct sockaddr_in *)&ifreq.ifr_addr)->sin_addr,
                       sizeof(struct in_addr));
            } else
                mreq.imr_interface.s_addr = htonl(INADDR_ANY);


            return (setsockopt(sockfd, IPPROTO_IP, IP_ADD_SOURCE_MEMBERSHIP,
                               &mreq, sizeof(mreq)));
        }

        case AF_INET6 :  /* IPv6 source-specific API is MCAST_JOIN_SOURCE_GROUP */
        default :
            errno = EAFNOSUPPORT;

            return (-1);
    }  /* switch */
}  /* mcast_join_source_group */

void Mcast_join_source_group(int                     sockfd,
                             const struct sockaddr * src,
                             socklen_t               srclen,
                             const struct sockaddr * grp,
                             socklen_t               grplen,
                             const char            * ifname,
                             u_int                   ifindex) {
    if (mcast_join_source_group(sockfd, src, srclen, grp, grplen,
                                ifname, ifindex) < 0) fprintf(stderr, "mcast_join_source_group error: %d - %s", errno, strerror(errno));
}

int udp_client(const char * host, const char * serv, struct sockaddr ** saptr, socklen_t * lenp) {
    int               sockfd, n;
    struct addrinfo   hints, * res, * ressave;

    bzero(&hints, sizeof(struct addrinfo));
    hints.ai_family   = AF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;

    if ((n = getaddrinfo(host, serv, &hints, &res)) != 0) fprintf(stderr, "udp_client error for %s, %s: %s", host, serv, gai_strerror(n));

    ressave = res;

    do {
        sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
        if (sockfd >= 0) break;  /* success */
    } while ((res = res->ai_next) != NULL);

    if (res == NULL)             /* errno set from final socket() */
        fprintf(stderr, "udp_client error for %s, %s", host, serv);

    *saptr = malloc(res->ai_addrlen);
    memcpy(*saptr, res->ai_addr, res->ai_addrlen);
    *lenp = res->ai_addrlen;

    freeaddrinfo(ressave);

    return (sockfd);
}

/* end udp_client */

int Udp_client(const char * host, const char * serv, struct sockaddr ** saptr, socklen_t * lenptr) {
    return (udp_client(host, serv, saptr, lenptr));
}

int Accept(int fd, struct sockaddr * sa, socklen_t * salenptr) {
    int   n;

again:
    if ((n = accept(fd, sa, salenptr)) < 0) {
#ifdef  EPROTO
        if (errno == EPROTO || errno == ECONNABORTED)
#else
        if (errno == ECONNABORTED)
#endif
            goto again;
        else fprintf(stderr, "accept error: %d - %s", errno, strerror(errno));
    }

    return (n);
}

void Bind(int fd, const struct sockaddr * sa, socklen_t salen) {
    if (bind(fd, sa, salen) < 0) fprintf(stderr, "bind error: %d - %s", errno, strerror(errno));
}

void Connect(int fd, const struct sockaddr * sa, socklen_t salen) {
    if (connect(fd, sa, salen) < 0) fprintf(stderr, "connect error: %d - %s", errno, strerror(errno));
}

void Getpeername(int fd, struct sockaddr * sa, socklen_t * salenptr) {
    if (getpeername(fd, sa, salenptr) < 0) fprintf(stderr, "getpeername error: %d - %s", errno, strerror(errno));
}

void Getsockname(int fd, struct sockaddr * sa, socklen_t * salenptr) {
    if (getsockname(fd, sa, salenptr) < 0) fprintf(stderr, "getsockname error: %d - %s", errno, strerror(errno));
}

void Getsockopt(int fd, int level, int optname, void * optval, socklen_t * optlenptr) {
    if (getsockopt(fd, level, optname, optval, optlenptr) < 0) fprintf(stderr, "getsockopt error: %d - %s", errno, strerror(errno));
}

int Inet6_rth_space(int type, int segments) {
    int   ret;

    ret = inet6_rth_space(type, segments);
    if (ret < 0) fprintf(stderr, "inet6_rth_space error: %d - %s", errno, strerror(errno));

    return ret;
}

void * Inet6_rth_init(void * rthbuf, socklen_t rthlen, int type, int segments) {
    void * ret;

    ret = inet6_rth_init(rthbuf, rthlen, type, segments);
    if (ret == NULL) fprintf(stderr, "inet6_rth_init error: %d - %s", errno, strerror(errno));

    return ret;
}

void Inet6_rth_add(void * rthbuf, const struct in6_addr * addr) {
    if (inet6_rth_add(rthbuf, addr) < 0) {
        fprintf(stderr, "inet6_rth_add error: %d - %s", errno, strerror(errno));
        exit(-1);
    }
}

void Inet6_rth_reverse(const void * in, void * out) {
    if (inet6_rth_reverse(in, out) < 0) {
        fprintf(stderr, "inet6_rth_reverse error: %d - %s", errno, strerror(errno));
        exit(-1);
    }
}

int Inet6_rth_segments(const void * rthbuf) {
    int   ret;

    ret = inet6_rth_segments(rthbuf);
    if (ret < 0) {
        fprintf(stderr, "inet6_rth_segments error: %d - %s", errno, strerror(errno));
        exit(-1);
    }

    return ret;
}

struct in6_addr * Inet6_rth_getaddr(const void * rthbuf, int idx) {
    struct in6_addr * ret;

    ret = inet6_rth_getaddr(rthbuf, idx);
    if (ret == NULL) {
        fprintf(stderr, "inet6_rth_getaddr error: %d - %s", errno, strerror(errno));
        exit(-1);
    }

    return ret;
}

int Kqueue(void) {
    int   ret;

    if ((ret = kqueue()) < 0) fprintf(stderr, "kqueue error: %d - %s", errno, strerror(errno));

    return ret;
}

int Kevent(int kq, const struct kevent * changelist, int nchanges,
           struct kevent * eventlist, int nevents, const struct timespec * timeout) {
    int   ret;

    if ((ret = kevent(kq, changelist, nchanges,
                      eventlist, nevents, timeout)) < 0) fprintf(stderr, "kevent error: %d - %s", errno, strerror(errno));

    return ret;
}

/* include Listen */
void Listen(int fd, int backlog) {
    char * ptr;

    /*4can override 2nd argument with environment variable */
    if ((ptr = getenv("LISTENQ")) != NULL) backlog = atoi(ptr);

    if (listen(fd, backlog) < 0) fprintf(stderr, "listen error: %d - %s", errno, strerror(errno));
}

/* end Listen */

int Poll(struct pollfd * fdarray, unsigned int nfds, int timeout) {
    int   n;

    if ((n = poll(fdarray, nfds, timeout)) < 0) fprintf(stderr, "poll error: %d - %s", errno, strerror(errno));

    return (n);
}

ssize_t Recv(int fd, void * ptr, size_t nbytes, int flags) {
    ssize_t   n;

    if ((n = recv(fd, ptr, nbytes, flags)) < 0) fprintf(stderr, "recv error: %d - %s", errno, strerror(errno));

    return (n);
}

ssize_t Recvfrom(int fd, void * ptr, size_t nbytes, int flags,
                 struct sockaddr * sa, socklen_t * salenptr) {
    ssize_t   n;

    if ((n = recvfrom(fd, ptr, nbytes, flags, sa, salenptr)) < 0) fprintf(stderr, "recvfrom error: %d - %s", errno, strerror(errno));

    return (n);
}

ssize_t Recvmsg(int fd, struct msghdr * msg, int flags) {
    ssize_t   n;

    if ((n = recvmsg(fd, msg, flags)) < 0) fprintf(stderr, "recvmsg error: %d - %s", errno, strerror(errno));

    return (n);
}

int Select(int nfds, fd_set * readfds, fd_set * writefds, fd_set * exceptfds,
           struct timeval * timeout) {
    int   n;

    if ((n = select(nfds, readfds, writefds, exceptfds, timeout)) < 0) fprintf(stderr, "select error: %d - %s", errno, strerror(errno));

    return (n);  /* can return 0 on timeout */
}

void Send(int fd, const void * ptr, size_t nbytes, int flags) {
    if (send(fd, ptr, nbytes, flags) != (ssize_t)nbytes) fprintf(stderr, "send error: %d - %s", errno, strerror(errno));
}

void Sendto(int fd, const void * ptr, size_t nbytes, int flags,
            const struct sockaddr * sa, socklen_t salen) {
    if (sendto(fd, ptr, nbytes, flags, sa, salen) != (ssize_t)nbytes) fprintf(stderr, "sendto error: %d - %s", errno, strerror(errno));
}

void Sendmsg(int fd, const struct msghdr * msg, int flags) {
    unsigned int   i;
    ssize_t        nbytes;

    nbytes = 0;  /* must first figure out what return value should be */
    for (i = 0; i < msg->msg_iovlen; i++) {
        nbytes += msg->msg_iov[i].iov_len;
    }

    if (sendmsg(fd, msg, flags) != nbytes) fprintf(stderr, "sendmsg error: %d - %s", errno, strerror(errno));
}

void Setsockopt(int fd, int level, int optname, const void * optval, socklen_t optlen) {
    if (setsockopt(fd, level, optname, optval, optlen) < 0) fprintf(stderr, "setsockopt error: %d - %s", errno, strerror(errno));
}

void Shutdown(int fd, int how) {
    if (shutdown(fd, how) < 0) fprintf(stderr, "shutdown error: %d - %s", errno, strerror(errno));
}

int Sockatmark(int fd) {
    int   n;

    if ((n = sockatmark(fd)) < 0) fprintf(stderr, "sockatmark error: %d - %s", errno, strerror(errno));

    return (n);
}

/* include Socket */
int Socket(int family, int type, int protocol) {
    int   n;

    if ((n = socket(family, type, protocol)) < 0) fprintf(stderr, "socket error: %d - %s", errno, strerror(errno));

    return (n);
}

/* end Socket */

void Socketpair(int family, int type, int protocol, int * fd) {
    int   n;

    if ((n = socketpair(family, type, protocol, fd)) < 0) fprintf(stderr, "socketpair error: %d - %s", errno, strerror(errno));
}

void * Malloc(size_t size) {
    void * ptr;

    if ((ptr = malloc(size)) == NULL) fprintf(stderr, "malloc error: %d - %s", errno, strerror(errno));

    return (ptr);
}

char * sock_ntop(const struct sockaddr * sa, socklen_t salen) {
    char          portstr[8];
    static char   str[128]; /* Unix domain is largest */

    switch (sa->sa_family) {
        case AF_INET : {
            struct sockaddr_in * sin = (struct sockaddr_in *)sa;

            if (inet_ntop(AF_INET, &sin->sin_addr, str, sizeof(str)) == NULL) return (NULL);

            if (ntohs(sin->sin_port) != 0) {
                snprintf(portstr, sizeof(portstr), ":%d", ntohs(sin->sin_port));
                strcat(str, portstr);
            }

            return (str);
        }
            /* end sock_ntop */

#ifdef  IPV6
        case AF_INET6 : {
            struct sockaddr_in6 * sin6 = (struct sockaddr_in6 *)sa;

            str[0] = '[';
            if (inet_ntop(AF_INET6, &sin6->sin6_addr, str + 1, sizeof(str) - 1) == NULL) return (NULL);

            if (ntohs(sin6->sin6_port) != 0) {
                snprintf(portstr, sizeof(portstr), "]:%d", ntohs(sin6->sin6_port));
                strcat(str, portstr);

                return (str);
            }

            return (str + 1);
        }
#endif  /* ifdef  IPV6 */

#ifdef  AF_UNIX
        case AF_UNIX : {
            struct sockaddr_un * unp = (struct sockaddr_un *)sa;

            /* OK to have no pathname bound to the socket: happens on
             * every connect() unless client calls bind() first. */
            if (unp->sun_path[0] == 0) strcpy(str, "(no pathname bound)");
            else snprintf(str, sizeof(str), "%s", unp->sun_path);

            return (str);
        }
#endif  /* ifdef  AF_UNIX */

#ifdef  HAVE_SOCKADDR_DL_STRUCT
        case AF_LINK : {
            struct sockaddr_dl * sdl = (struct sockaddr_dl *)sa;

            if (sdl->sdl_nlen > 0)
                snprintf(str, sizeof(str), "%*s (index %d)",
                         sdl->sdl_nlen, &sdl->sdl_data[0], sdl->sdl_index);
            else
                snprintf(str, sizeof(str), "AF_LINK, index=%d", sdl->sdl_index);


            return (str);
        }
#endif  /* ifdef  HAVE_SOCKADDR_DL_STRUCT */
        default :
                snprintf(str, sizeof(str), "sock_ntop: unknown AF_xxx: %d, len %d",
                     sa->sa_family, salen);

            return (str);
    } /* switch */

    return (NULL);
}     /* sock_ntop */

char * Sock_ntop(const struct sockaddr * sa, socklen_t salen) {
    char * ptr;

    if ((ptr = sock_ntop(sa, salen)) == NULL) err_sys("sock_ntop error"); /* inet_ntop() sets errno
                                                                          **/

    return (ptr);
}

void loop(int sockfd, socklen_t salen) {
    socklen_t         len;
    ssize_t           n;
    char            * p;
    struct sockaddr * sa;
    struct sap_packet {
        uint32_t sap_header;
        uint32_t sap_src;
        char     sap_data[BUFFSIZE];

    }   buf;

    sa = Malloc(salen);

    for ( ; ; ) {
        len               = salen;
        n                 = Recvfrom(sockfd, &buf, sizeof(buf) - 1, 0, sa, &len);
        ((char *)&buf)[n] = 0;  /* null terminate */
        buf.sap_header    = ntohl(buf.sap_header);

            printf("From %s hash 0x%04x\n",            Sock_ntop(sa, len),
               buf.sap_header & SAP_HASH_MASK);
        if (((buf.sap_header & SAP_VERSION_MASK) >> SAP_VERSION_SHIFT) > 1) {
            printf("... version field not 1 (0x%08x)", buf.sap_header);
            continue;
        }

        if (buf.sap_header & SAP_IPV6) {
            err_msg("... IPv6");
            continue;
        }

        if (buf.sap_header & (SAP_DELETE | SAP_ENCRYPTED | SAP_COMPRESSED)) {
            err_msg("... can't parse this packet type (0x%08x)", buf.sap_header);
            continue;
        }

        p = buf.sap_data + ((buf.sap_header & SAP_AUTHLEN_MASK) >> SAP_AUTHLEN_SHIFT);
        if (strcmp(p, "application/sdp") == 0) p += 16;

        printf("%s\n", p);
    }
}

int tcp_connect(const char * host, const char * serv) {
    int               sockfd, n;
    struct addrinfo   hints, * res, * ressave;

    bzero(&hints, sizeof(struct addrinfo));
    hints.ai_family   = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if ((n = getaddrinfo(host, serv, &hints, &res)) != 0)
        err_quit("tcp_connect error for %s, %s: %s",
                 host, serv, gai_strerror(n));

    ressave = res;

    do {
        sockfd = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
        if (sockfd < 0) continue;                                        /* ignore this one */

        if (connect(sockfd, res->ai_addr, res->ai_addrlen) == 0) break;  /* success */

        close(sockfd);                                                   /* ignore this one */
    } while ((res = res->ai_next) != NULL);

    if (res == NULL)                                                     /* errno set from final
                                                                          * connect() */
        err_sys("tcp_connect error for %s, %s", host, serv);

    freeaddrinfo(ressave);

    return (sockfd);
}

/* end tcp_connect */

/*
 * We place the wrapper function here, not in wraplib.c, because some
 * XTI programs need to include wraplib.c, and it also defines
 * a Tcp_connect() function.
 */
int Tcp_connect(const char * host, const char * serv) {
    return (tcp_connect(host, serv));
}

