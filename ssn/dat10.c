/* 
    *.datファイルの0x10ブロックを stdin から入れる。
    dat10 < y0001 | less
*/


#include <stdio.h>

unsigned char buff[256];

#define unpack(a,b,c,d) (a<<24|b<<16|c<<8|d)

FILE *fp;

int item ()
{
  int i_num;
  int n_item;
  int i, pos=0;

  fread (buff, 1, 1, fp);
  pos += 1;
  i_num = unpack (0, 0, 0, buff[0]);

  fread (buff, 1, 1, fp);
  if (buff[0] == 0xff) {
    fread (buff, 3, 1, fp);
    n_item = buff[0];
    pos += 4;
  } else {
    ungetc (buff[0], fp);
    n_item = 1;
  }
    
  for (i=1; i<=n_item; i++) {
    int type;
    int size;
    fread (buff, 1, 1, fp);
    type = buff[0];
    pos += 1;
    printf ("%02x %02x %02x: ", i_num, i, type);
    if (type == 0x0f) {	/* @Value.dat 内の分割されたマルチメディアデータ */
      fread (buff, 2, 1, fp);
      size = unpack (0, 0, buff[0], buff[1]);
      printf ("size=0x%x\n", size);
      fseek (fp, size, SEEK_CUR);
      pos += size+2;
    } else if (type >= 0x10) {	/* マルチメディアデータ */
      int mm_id, mm_size;
      fread (buff, 1, 1, fp);
      size = unpack (0, 0, 0, buff[0]);
      fread (buff, size, 1, fp);
      mm_id = unpack (0, buff[0], buff[1], buff[2]);
      mm_size = unpack (buff[3], buff[4], buff[5], buff[6]);
      printf ("mm_id=%d size=0x%x\n", mm_id, mm_size);
      pos += size+1;
    } else if (type >= 0x06 && type <= 0x08) { /* 文字列 */
      fread (buff, 1, 1, fp);
      size = unpack (0, 0, 0, buff[0]);
      fread (buff, size, 1, fp);
      buff[size] = 0;
      printf ("%s\n", buff);
      pos += size+1;
    } else {			/* その他の一般データ型 */
      fread (buff, 1, 1, fp);
      size = unpack (0, 0, 0, buff[0]);
      printf ("size=0x%x\n", size);
      fseek (fp, size, SEEK_CUR);
      pos += size+1;
    }
  }
  return pos;
}

int record ()
{
  int r_num;
  int size;
  int i;

  fread (buff, 3, 1, fp);
  r_num = unpack (0, buff[0], buff[1], buff[2]);

  printf ("record#: %d\n", r_num);

  fread (buff, 2, 1, fp);
  size = unpack (0, 0, buff[0], buff[1]);

  for (i=0; i<size;){
    i+=item();
  }

  return size + 5;
}

void block ()
{
  int block_size;
  int i;

  fread (buff, 2, 1, fp);

  if (buff[0] != 0x10 || buff[1] != 0x00) {
    printf ("not 0x10 0x00\n");
    return;
  }

  fread (buff, 2, 1, fp);
  block_size = unpack (0, 0, buff[0], buff[1]);

  //printf ("bs: %d\n", block_size);

  for (i=4; i<block_size; i+=record ())
    ;


}

int main (int argc, char *argv[])
{
  fp = stdin;

  block ();

  return 0;
}
