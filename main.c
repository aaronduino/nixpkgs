#include <string.h>
#include <stdio.h>
#include <zlib.h>

int main() {
   char a[50] = "Hello, world!";
   char b[50];
   char c[50];

   uLong ucompSize = strlen(a)+1; // "Hello, world!" + NULL delimiter.
   uLong compSize = compressBound(ucompSize);

   // Deflate
   compress((Bytef *)b, &compSize, (Bytef *)a, ucompSize);

   // Inflate
   uncompress((Bytef *)c, &ucompSize, (Bytef *)b, compSize);

   printf("%s\n", a);
   printf("%s\n", b);
   printf("%s\n", c);
   return 0;
}

