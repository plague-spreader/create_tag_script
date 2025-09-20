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
    local album_title=$(echo $album_content | xmllint\
        --xpath '//h1[contains(@class, "album_name")]/a/text()' -)
    local band_name=$(echo $album_content | xmllint\
        --xpath '//h2[contains(@class, "band_name")]/a/text()' -)
    local release_date=$(echo $album_content | xmllint\
        --xpath '//div[@id="album_info"]/dl[contains(@class, "float_left")]/dd[2]/text()' -)
    local songs=$(echo $album_content | xmllint\
        --xpath '//table[contains(@class, "table_lyrics")]//tr[contains(@class, "even") or contains(@class, "odd")]/td[2]/text()' - |\
        sed -Ee 's:^\s*::; s:\s*$::g')
    # ^ I need a consistent separator for iterating through songs
    # and I'm betting no song has an ASCII non-printable character
    IFS=
    local songs_arr=(${songs})
    local num_songs=${#songs_arr[@]}
    echo '#!/usr/bin/env bash' > tag_id3.sh
    echo >> tag_id3.sh
    local i=1
    for song in $songs; do
        IFS=$' \t\n'
        echo id3tag -a \"${band_name}\" -A \"${album_title}\"\
            -y \"${release_date}\" -s \"$(echo ${song} | xargs)\" -t ${i}\
            -T ${num_songs} filename >> tag_id3.sh
        let i++
        IFS=
    done
    IFS=$' \t\n'
    chmod +x tag_id3.sh

    echo Review tag_id3.sh and then execute it to tag your songs
}

if [ $# -lt 1 ]; then
    >&2 usage
    exit 1
fi

url=$1

if echo $url | grep -q 'metal-archives\.com'; then
    from_metal_archives ${url}
else
    echo Non-existent id3 tag provider
fi
