struct deftok {
    struct tokv_t tok;
    struct deftok *next;
};

enum defdicttype { DEFNUM, DEFID, DEFPARAMS };
struct defdictval {
    char *key;
    enum defdicttype type;
    char *defvalue;
    int ivalue;
    struct deftok *head;
};
int defdictputval(struct defdictval *);
int defdictgetval(const char *, struct defdictval *);
void defdictprint(int);
