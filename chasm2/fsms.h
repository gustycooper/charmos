#include "chasm_types.h"
int isid(char *);
int isnumber(char *);
int isfloat(char *);
int isreg(char *);
int isinst(struct toki_t t);
int validmacro(struct toki_t t);
int validexpand(struct toki_t t);
