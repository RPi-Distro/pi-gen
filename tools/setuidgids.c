#include <sys/types.h>
#include <pwd.h>
#include <unistd.h>
#include <grp.h>
#include <stdio.h>
#include <stdlib.h>

static int prot_gid(gid_t gid)
{
  if (setgroups(1,&gid) == -1) return -1;
  return setgid(gid); /* _should_ be redundant, but on some systems it isn't */
}

const char *account;
struct passwd *pw;

int main(int argc, char **argv, char **envp)
{
  account = *++argv;
  if (!account || !*++argv) {
    fprintf(stderr, "setuidgids: usage: setuidgids account child");
    exit(EXIT_FAILURE);
  }

  pw = getpwnam(account);
  if (!pw) {
    fprintf(stderr, "setuidgids: FATAL: unknown account %s", account);
    return EXIT_FAILURE;
  }

  if (prot_gid(pw->pw_gid) == -1) {
    fprintf(stderr, "setuidgids: FATAL: unable to setgid\n");
    return EXIT_FAILURE;
  }
  if (initgroups(pw->pw_name, pw->pw_gid) == -1) {
    fprintf(stderr, "setuidgids: FATAL: unable to initgroups\n");
    return EXIT_FAILURE;
  }
  if (setuid(pw->pw_uid) == -1) {
    fprintf(stderr, "setuidgids: FATAL: unable to setuid\n");
    return EXIT_FAILURE;
  }

  execvpe(*argv,argv,envp);
  fprintf(stderr, "setuidgids: FATAL: unable to run %s\n", *argv);
  return EXIT_FAILURE;
}
