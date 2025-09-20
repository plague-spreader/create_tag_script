# create_tag_script

Create ID3 script for tagging mp3 easily

## Usage

```create_tag_script.sh <URL>```

## Description

The program supports multiple URL providers (only metal-archives for now) and
will connect to the specified website (if the provider is available) to
download the album info and create the ```tag_id3.sh``` script.

Afterwards you should check that script and modify it according to your
preferences and, most importantly, to write the actual filenames in your
filesystem

## Dependencies

* [xmllint](https://linux.die.net/man/1/xmllint)
* [id3tag](https://man.archlinux.org/man/id3tag.1.en)

## Example usage

```./create_tag_script.sh https://www.metal-archives.com/albums/Teitanblood/Death/401235```

Will create the following file


    #!/usr/bin/env bash
    
    id3tag -a "Teitanblood" -A "Death" -y "March 13th, 2014" -s "Anteinfierno" -t 1 -T 7 filename
    id3tag -a "Teitanblood" -A "Death" -y "March 13th, 2014" -s "Sleeping Throats of the Antichrist" -t 2 -T 7 filename
    id3tag -a "Teitanblood" -A "Death" -y "March 13th, 2014" -s "Plagues of Forgiveness" -t 3 -T 7 filename
    id3tag -a "Teitanblood" -A "Death" -y "March 13th, 2014" -s "Cadaver Synod" -t 4 -T 7 filename
    id3tag -a "Teitanblood" -A "Death" -y "March 13th, 2014" -s "Unearthed Veins" -t 5 -T 7 filename
    id3tag -a "Teitanblood" -A "Death" -y "March 13th, 2014" -s "Burning in Damnation Fires" -t 6 -T 7 filename
    id3tag -a "Teitanblood" -A "Death" -y "March 13th, 2014" -s "Silence of the Great Martyrs" -t 7 -T 7 filename

Then you need to modify each ```filename``` and year field accordingly
