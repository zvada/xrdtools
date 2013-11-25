#include <sys/time.h>
#include <time.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

volatile char *r;

void handler(int sig)
{
    time_t t;

    time(&t);
    r = ctime(&t);
}

int main()
{
    struct itimerval it;
    struct sigaction sa;
    time_t t;
    int counter = 0;

    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handler;
    sigaction(SIGALRM, &sa, NULL);

    it.it_value.tv_sec = 0;
    it.it_value.tv_usec = 1000;
    it.it_interval.tv_sec = 0;
    it.it_interval.tv_usec = 1000;
    setitimer(ITIMER_REAL, &it, NULL);

    while(1) {
        counter++;
        time(&t);
        r = ctime(&t);
        printf("Loop %d\n",counter);
    }

    return 0;
}
