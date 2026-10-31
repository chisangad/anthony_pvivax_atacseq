#Reannotate concensus peaks
source ~/.bashrc
#Set workdir to the parent directory of the script's location
path2root=$(realpath $(dirname $0)|xargs -n1 dirname)
cd ${path2root}
annotatePeaks.pl ${path2root}/output/NFCore_ATACseq/bwa/merged_library/macs2/narrow_peak/consensus/consensus_peaks.mLb.clN.bed  hg38 -cpu 6 > \
${path2root}/output/NFCore_ATACseq/bwa/merged_library/macs2/narrow_peak/consensus/consensus_peaks.mLb.clN.annotatePeaks2.txt