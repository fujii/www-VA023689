#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define oct_cat4(a, b, c, d) ((a << 24) | (b << 16) | (c << 8) | d)
#define oct_cat2(a, b) ((a << 8) | b)

#define oct_read(dest, size, fp) fread(dest, size, 1, fp)
#define oct_write(src, size, fp) fwrite(src, size, 1, fp)
#define oct_seek fseek

void
extend_sseddata (FILE *fp_dic, char *filename_prefix)
{
  unsigned int i;
  unsigned char header[64];
  unsigned char buff[4];
  unsigned int n_chunk;
  unsigned int *offset;
  char cookie[] = "SSEDDATA";


  oct_read (header, sizeof header, fp_dic);

  if (strncmp (header, cookie, strlen (cookie)))
    {
      fprintf (stderr, "This is not a SSEDDATA file.\n");
      exit (1);
    }

  n_chunk = oct_cat2 (header[22], header[23]);
  offset = calloc (n_chunk, sizeof(*offset));

  for (i=0; i<n_chunk; i++)
    {
      oct_read (buff, 4, fp_dic);
      offset[i] = oct_cat4 (buff[0], buff[1], buff[2], buff[3]);
    }

  for (i=0; i<n_chunk; i++)
    {
      int n_data;
      unsigned char win[0xff0];
      int d;
      unsigned int wintop = 0;
      unsigned int pos = 0;
      char filename[256];
      FILE *fp_out;

      sprintf (filename, "%s%04x", filename_prefix, i);
      fp_out = fopen (filename, "wb");
      assert (fp_out);

      oct_seek (fp_dic, offset[i]+2, SEEK_SET);

      oct_read (buff, 3, fp_dic);

      n_data = oct_cat2 (buff[0], buff[1]);

      /* スライド窓の初期化 */
      memset (win, buff[2], sizeof win);

      for (d=0; d<n_data; d++)
	{
	  int j;
	  int wp, len, w;
	  oct_read (buff, 3, fp_dic);

	  wp = ((int)buff[0] << 4) | (buff[1] >> 4);
	  len = buff[1] & 0x0f;

	  for (j=0; j<len; j++)
	    {
	      w = wp + wintop;
	      if (w >= sizeof win)
		w -= sizeof win;
	      win[wintop] = win[w];
	      wintop ++;
	      if (wintop >= sizeof win)
		wintop = 0;
	      oct_write (&win[w], 1, fp_out);
	      pos ++;
	    }

	  /*
	   *  最後のデータで、既に2048の倍数バイト出力している
	   */
	  if (d == n_data-1 && !(pos & 0x7ff))
	    break;

	  win[wintop] = buff[2];
	  wintop ++;
	  if (wintop >= sizeof win)
	    wintop = 0;
	  oct_write (&buff[2], 1, fp_out);
	  pos ++;

	}

      fclose (fp_out);

    }

  return;
}

int
main (int argc, char *argv[])
{

  assert (argc == 3);

  extend_sseddata (fopen (argv[1], "rb"), argv[2]);

  return 0;
}
