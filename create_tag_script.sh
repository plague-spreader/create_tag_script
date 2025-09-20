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
    album_title=$(echo $album_content | xmllint\
        --xpath '//h1[contains(@class, "album_name")]/a/text()' -)
    band_name=$(echo $album_content | xmllint\
        --xpath '//h2[contains(@class, "band_name")]/a/text()' -)
    album_year=$(echo $album_content | xmllint\
        --xpath '//div[@id="album_info"]/dl[contains(@class, "float_left")]/dd[2]/text()' -)
    local songs_str=$(echo $album_content | xmllint\
        --xpath '//table[contains(@class, "table_lyrics")]//tr[contains(@class, "even") or contains(@class, "odd")]/td[2]/text()' - | tr '\n' )
    songs_str=$(echo $songs_str | sed -Ee 's:\s+\s+::g')
    # ^ I need a consistent separator for iterating through songs
    # and I'm betting no song has an ASCII non-printable character
    IFS= songs=(${songs_str})
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
