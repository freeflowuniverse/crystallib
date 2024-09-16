


function s3_configure {

SECRET_FILE="/${HOME}/code/git.ourworld.tf/despiegk/hero_secrets/mysecrets.sh"
if [ -f "$SECRET_FILE" ]; then
    echo get secrets
    source "$SECRET_FILE"
fi    

# Check if environment variables are set
if [ -z "$S3KEYID" ] || [ -z "$S3APPID" ]; then
    echo "Error: S3KEYID or S3APPID is not set"
    exit 1
fi

# Create rclone config file
mkdir -p "${HOME}/.config/rclone"
cat > "${HOME}/.config/rclone/rclone.conf" <<EOL
[b2]
type = b2
account = $S3KEYID
key = $S3APPID
hard_delete = true
EOL

echo "made S3 config on: ${HOME}/.config/rclone/rclone.conf"

cat ${HOME}/.config/rclone/rclone.conf

}

