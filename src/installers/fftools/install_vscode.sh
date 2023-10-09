set -ex

pushd /tmp
rm -f vscode.zip
curl -L '@url' -o vscode.zip

rm -rf Visual\ Studio\ Code.app
rm -rf /Applications/Visual\ Studio\ Code.app

unzip vscode.zip

rsync -rav Visual\ Studio\ Code.app/ /Applications/Visual\ Studio\ Code.app/

rm -f vscode.zip
rm -rf Visual\ Studio\ Code.app


popd

echo "VSCODE INSTALLED SUCCESFULLY"