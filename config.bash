# study directories
STUDIES=(reward multimodal pet coglong p5)
reward="/data/Luna1/Raw/MRRC_Org/*/*/*/"
multimodal="/Volumes/Phillips/Raw/MRprojects/MultiModal/*/*/*/"
pet="/Volumes/Phillips/Raw/MRprojects/mMRDA-dev/*/*/*/"

coglong="/Volumes/Phillips/Raw/MRprojects/CogLong/*/*/*/"
p5="/Volumes/Phillips/Raw/MRprojects/P5Sz/*/*/*/"

# find the raw root directory of one of the above
# ie. remove all the */'s
rawrootof() { echo "$1" | sed 's:/\*/\*/\*/::'; }

# different setup!
#  CogLong/100908171452/001/protcol

warn() { echo $@ >&2; }
exiterr() { warn $@; exit 1;}
