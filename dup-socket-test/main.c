#include <stdio.h>
#include <errno.h>
#include <assert.h>
#include <string.h>
#include <stdbool.h>
#include <arpa/inet.h>
#include <netdb.h> 
#include <netinet/in.h> 
#include <stdlib.h> 
#include <string.h> 
#include <sys/socket.h> 
#include <sys/types.h> 
#include <unistd.h>

#define POSIX_ASSERT(x) if (!(x)) { fprintf(stderr, "Assert (%s) failed: %s\n", #x, strerror(errno)); exit(1); }

int makeServer(int port) {
    int sockfd = socket(AF_INET, SOCK_STREAM, 0); 
    if (sockfd == -1) {
        return sockfd;
    }
    struct sockaddr_in addr = {
        .sin_family = AF_INET,
        .sin_addr = {
            .s_addr = htonl(INADDR_ANY),
        },
        .sin_port = htons(port),
    };

    if ((bind(sockfd, &addr, sizeof(addr))) != 0) {
        close(sockfd);
        return -1;
    }
    if (listen(sockfd, 5) != 0) {
        close(sockfd);
        return -1;
    }
    return sockfd;
}

int myAccept(int server) {
    struct sockaddr_in dummy;
    socklen_t len = sizeof(dummy);
    return accept(server, &dummy, &len);
}

bool fputs2(int fd, const char* msg) {
    size_t len = strlen(msg);
    ssize_t out = write(fd, msg, len);
    return out == len;
}

int makeClient(const char* ip, int port) {
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1) {
        return sockfd;
    }
    struct sockaddr_in addr = {
        .sin_family = AF_INET,
        .sin_addr = {
            .s_addr = inet_addr(ip),
        },
        .sin_port = htons(port),
    };
    if (connect(sockfd, &addr, sizeof(addr)) != 0) {
        close(sockfd);
        return -1;
    }
    return sockfd;
}

int main(int argc, char** argv) {
    int server = makeServer(6969);
    assert(server != -1);
    int clientToMe = myAccept(server);
    POSIX_ASSERT(clientToMe != -1);
    // POSIX_ASSERT(fputs2(client, "Hello from server"));
    int clientOfMine = makeClient("127.0.0.1", 6970);
    POSIX_ASSERT(clientOfMine != -1);
    POSIX_ASSERT(fputs2(clientOfMine, "hello from clinet"));
    POSIX_ASSERT(dup2(clientOfMine, clientToMe) != -1);
    while (true) {};
}
