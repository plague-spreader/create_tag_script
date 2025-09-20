#!/usr/bin/env bash

usage() {
    <<EOF cat
Usage: $0 <URL>
EOF
}

from_metal_archives() {
    local url=$1

    if ! echo ${url} | grep -q /albums/; then
        echo Invalid metal-archives albums URL \"${url}\"
        exit 1
    fi

    local album_content=$(curl -s ${url}| xmllint --html\
        --xpath '//div[@id="album_content"]' -)
    album_title=$(echo ${album_content} | xmllint\
        --xpath '//h1[contains(@class, "album_name")]/a/text()' -)
    band_name=$(echo ${album_content} | xmllint\
        --xpath '//h2[contains(@class, "band_name")]/a/text()' -)
    album_year=$(echo ${album_content} | xmllint\
        --xpath '//div[@id="album_info"]/dl[contains(@class, "float_left")]/dd[2]/text()' -)
    local songs_str=$(echo ${album_content} | xmllint\
        --xpath '//table[contains(@class, "table_lyrics")]//tr[contains(@class, "even") or contains(@class, "odd")]/td[2]/text()' - | tr '\n' )
    songs_str=$(echo ${songs_str} | sed -Ee 's:\s+\s+::g')
    # ^ I need a consistent separator for iterating through songs
    # and I'm betting no song has an ASCII non-printable character
    IFS= songs=(${songs_str})
}

from_discogs() {
    local url=$1
    local page_content=$(curl -sA 'curl' ${url} | xmllint --html\
        --xpath '//div[@id="page"]' -)
    local band_and_album=$(echo ${page_content} | xmllint\
        --xpath '//h1[contains(@class, "MuiTypography-")]' -)
    band_name=$(echo ${band_and_album} | xmllint --xpath '/h1/span/a/text()' -)
    album_title=$(echo ${band_and_album} | xmllint --xpath '/h1/text()[2]' -)
    album_year=$(echo ${page_content} | xmllint\
        --xpath '//div[contains(@class, "body_")]//time/text()' -)
    IFS= songs=($(echo ${page_content} | xmllint\
        --xpath '//td[contains(@class, "trackTitle")]/span[1]//text()' - |\
        tr '\n' ))
}

if [ $# -lt 1 ]; then
    >&2 usage
    exit 1
fi

url=$1

case ${url} in
    *metal-archives.com*)
        from_metal_archives ${url}
        ;;
    *discogs.com*)
        from_discogs ${url}
        ;;
    *)
        echo Non-existent id3 tag provider
        exit 0
        ;;
esac

echo '#!/usr/bin/env bash' > tag_id3.sh
echo >> tag_id3.sh
for ((i = 0; i < ${#songs[@]};)); do
    echo id3tag -a \"${band_name}\" -A \"${album_title}\"\
        -y \"${album_year}\" -s \"${songs[$((i++))]}\" -t ${i} -T ${#songs[@]}\
            filename >> tag_id3.sh
done
chmod +x tag_id3.sh

echo Review tag_id3.sh and then execute it to tag your songs
