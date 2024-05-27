#!/bin/bash
set -ex
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CRYSTALPATH="$( cd "$BASE_DIR/../.." && pwd )"
#cd ${BASE_DIR}
source ${CRYSTALPATH}/tools/myenv.sh
python ${CRYSTALPATH}/tools/doc_extractor/extractor.py -s ${CRYSTALPATH}/crystallib -d ${CRYSTALPATH}/manual/libreadme