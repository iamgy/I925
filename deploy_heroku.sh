#! /bin/bash

cd $(dirname $0)

END="==================================="

# set default env
V2_ID=${V2_ID:-"d007eab8-ac2a-4a7f-287a-f0d50ef08680"}
V2_PATH=${V2_PATH:-"path"}
ALTER_ID=${ALTER_ID:-"1"}

if [ -z $HEROKU_ACCOUNT ]; then
    echo "HEROKU_ACCOUNT is empty, not deplay to heroku${END}"
    exit 0
fi

type heroku || {
    echo "download heroku cli${END}"
    sudo apt update
    sudo apt install -y vim-nox
    #curl https://cli-assets.heroku.com/install.sh | sudo bash
    exit 0
}

if [ ! -f "./config/v2ray" ]; then
    echo "download v2ray${END}"
    pushd ./config
    new_ver=$(curl -s https://github.com/v2fly/v2ray-core/releases/latest | grep -Po "(\d+\.){2}\d+")
    wget -q -Ov2ray.zip https://github.com/v2fly/v2ray-core/releases/download/v${new_ver}/v2ray-linux-64.zip
    if [ $? -eq 0 ]; then
        7z x v2ray.zip v2ray v2ctl
        chmod 700 v2ctl v2ray
    else
        echo "download new version failed!${END}"
        exit 1
    fi
    rm -fv v2ray.zip
    popd
fi

# v2ray config
cp -vf ./config/v2ray ./$IBM_APP_NAME/$IBM_APP_NAME
cp -vf ./config/v2ctl ./$IBM_APP_NAME/
{
    echo "#! /bin/bash"
    echo "wget https://raw.githubusercontent.com/$GITHUB_REPOSITORY/master/config/config.json"
    echo "sed 's/V2_ID/$V2_ID/' config.json -i"
    echo "sed 's/V2_PATH/$V2_PATH/' config.json -i"
    echo "sed 's/ALTER_ID/$ALTER_ID/' config.json -i"

} > ./$IBM_APP_NAME/d.sh
chmod +x ./$IBM_APP_NAME/d.sh

echo "heroku login${END}"
heroku login -i <<EOF
$HEROKU_ACCOUNT
EOF
