# study directories
STUDIES=(pet p5 reward coglong)

STUDIES_OLD=(coglongbirc coglongnic coglongdvd multimodalold)

reward="/data/Luna1/Raw/MRRC_Org/*/*/*/"
multimodal="/Volumes/Phillips/Raw/MRprojects/MultiModal/*/*/*/"
multimodalold="/data/Luna1/Raw/MultiModal/*/*/"
pet="/Volumes/Phillips/Raw/MRprojects/mMRDA-dev/*/*/*/"

p5="/Volumes/Phillips/Raw/MRprojects/P5Sz/*/*/*/"

coglong="/Volumes/Phillips/Raw/MRprojects/CogLong/*/*/"
coglongbirc="/data/Luna1/Raw/BIRC/*/*/"
coglongnic="/data/Luna1/Raw/NIC/*/*/"
coglongdvd="/data/Luna1/Raw/BIRC_from_DVDs/*/*/"

# find the raw root directory of one of the above
# ie. remove all the */'s
#rawrootof() { echo "$1" | sed 's:/\*/\*/\*/::'; }
rawrootof() { echo "$1" | sed 's:/\*::g;s:/\+$::'; }

# different setup!
#  CogLong/100908171452/001/protcol

warn() { echo $@ >&2; }
exiterr() { warn $@; exit 1;}
