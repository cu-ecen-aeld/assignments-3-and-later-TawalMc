#include <stdio.h>
#include <stdlib.h>
#include <syslog.h>

int main(int argc, char const *argv[])
{
    openlog(NULL, LOG_PID, LOG_USER);

    if (argc != 3)
    {
        syslog(LOG_ERR, "Missing argument. 2 arguments are required.\n");
        return EXIT_FAILURE;
    }

    FILE *writefile = fopen(argv[1], "w");
    if (!writefile)
    {
        syslog(LOG_ERR, "Could not open the file %s.\n", argv[1]);
        return EXIT_FAILURE;
    }

    syslog(LOG_DEBUG, "Writing %s to %s", argv[2], argv[1]);
    if (fputs(argv[2], writefile) == EOF)
    {
        syslog(LOG_ERR, "Error while writing %s to %s", argv[1], argv[2]);
        return EXIT_FAILURE;
    }

    if (fclose(writefile) == EOF)
    {
        syslog(LOG_ERR, "Error while closing file %s", argv[1]);
        return EXIT_FAILURE;
    }

    return 0;
}
