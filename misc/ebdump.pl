#! /usr/bin/perl

#
# Parse command line arguments.
#
die "usage: $0 file offset [lines]\n" if (@ARGV < 2 || 3 < @ARGV);
die "$0: invalid offset\n" if ($ARGV[1] !~ /^([0-9a-fA-F]+):([0-9a-fA-F]+)$/);
$offset = (hex($1) - 1) * 2048 + hex($2);
$file = $ARGV[0];
$length = (@ARGV == 2) ? 2048 : $ARGV[2] * 16;
die "$0: invalid offset\n" if ($offset < 0);

#
# Open a file.
#
open(FILE, $file) || die "$0: failed to open the file, $!: $file.\n";
seek(FILE, $offset, 0) || die "$0: failed to seek the file, $!: $file.\n";

#
# Read the file.
#
$count = 0;
while ($count < $length) {
    last if (read(FILE, $buf, 16) != 16);
    @data = unpack("C16", $buf);
    printf '%04x:%03x  ', $offset / 2048 + 1, $offset % 2048;
    for ($i = $0; $i < 16; $i += 2) {
	printf('%02x%02x', $data[$i], $data[$i + 1]);
    }
    print '  ';
    for ($i = $0; $i < 16; $i += 2) {
	if (0x21 <= $data[$i] && $data[$i] <= 0x7e
	    && 0x21 <= $data[$i + 1] && $data[$i + 1] <= 0x7e) {
		printf('[%c%c]', $data[$i] | 0x80, $data[$i + 1] | 0x80);
	} else {
		printf('%02x%02x', $data[$i], $data[$i + 1]);
	}
    }
    print "\n";
    $offset += 16;
    $count += 16;
}

#
# Close the file.
#
close(FILE);
