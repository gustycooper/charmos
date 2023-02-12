#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_LINE 100        // maximum length of asm prog line
static char buf[MAX_LINE];              // lines from .chasm file read into buf

#define INST_PER_LINE 4

int charm_insts_int[] = { 0x72646c, 0x62646c, 0x727473, 627473 };
char *charm_insts_str[] = { "ldr", "ldb", "str", "stb" };

enum inst_c { ldrstr, arithlog, movcmp, branch };
enum inst_t { ldr, str, add, mov, cmp, bal };
struct inst_info {
    int inst_int;
    char inst_str[4];
    enum inst_t inst_t;
    enum inst_c inst_c;
    char opcode;
};

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Error: Invoke as %% charm_tools filename\n");
        exit(-1);
    }

    FILE *fp;
    if ((fp = fopen(argv[1], "r")) == NULL)
        return -1;
    int lines = 0;
    int instructions = 0;
    int neednewline = 1;
    printf("enum inst_c {\n    ");
    while (fgets(buf, MAX_LINE, fp)) {
        ++lines;
        buf[strcspn(buf, "\n")] = '\0';
        if (buf[0] == '+') {
            if (neednewline)
                printf("\n");
            printf("};\n");
            instructions = 1;
            lines = 0;
            printf("enum inst_t {");
        }
        else {
            if (instructions)
                buf[3] = '\0';
            if (!neednewline)
                printf("    ");
            printf("%s, ", buf);
        }
        if (lines % INST_PER_LINE == 0) {
            printf("\n");
            neednewline = 0;
        }
        else
            neednewline = 1;
    }
    if (neednewline)
        printf("\n");
    printf("};\n");
    fclose(fp);

    printf("struct inst_info {\n");
    printf("    int inst_int;\n");
    printf("    char inst_str[4];\n");
    printf("    enum inst_t inst_t;\n");
    printf("    enum inst_c inst_c;\n");
    printf("    int opcode;\n");
    printf("};\n");
    if ((fp = fopen(argv[1], "r")) == NULL)
        return -1;
    lines = 0;
    instructions = 0;
    int opcode = 0;
    printf("struct inst_info ins[] = {");
    while (fgets(buf, MAX_LINE, fp)) {
        if (instructions) {
            buf[strcspn(buf, "\n")] = '\0';
            buf[3]  = '\0';  // Make buf be "ldr\0lsrstr\00x10"; 
            buf[10] = '\0';  // Make buf be "ldr\0lsrstr\00x10"; 
            if (lines % (INST_PER_LINE/2) == 0)
                printf("\n    ");
            printf("{0x%x, ", *(int *)buf);
            printf("\"%s\", ", buf);
            printf("%s, ", buf);
            printf("%s, ", buf+4);
            opcode = (int)strtol(buf+11, NULL, 16);
            printf("0x%08x}, ", opcode);
            ++lines;
        }
        if (buf[0] == '+')
            instructions = 1;
    }
    printf("\n};\n");
    fclose(fp);

    exit(0);

/***********/
    if ((fp = fopen(argv[1], "r")) == NULL)
        return -1;
    lines = 0;
    printf("int charm_insts_int[] = {\n    ");
    while (fgets(buf, MAX_LINE, fp)) {
        buf[strcspn(buf, "\n")] = '\0';
        printf("0x%x, ", *(int *)buf);
        if (++lines % INST_PER_LINE == 0)
            printf("\n    ");
    }
    if (lines % INST_PER_LINE == 0) 
        printf("                    };\n");
    else
        printf("\n                        };\n");
    fclose(fp);

    if ((fp = fopen(argv[1], "r")) == NULL)
        return -1;
    lines = 0;
    printf("char *charm_insts_str[] = {\n    ");
    while (fgets(buf, MAX_LINE, fp)) {
        buf[strcspn(buf, "\n")] = '\0';
        printf("\"%s\", ", buf);
        if (++lines % INST_PER_LINE == 0)
            printf("\n    ");
    }
    if (lines % INST_PER_LINE == 0) 
        printf("                      };\n");
    else
        printf("\n                          };\n");
    fclose(fp);
}
