#!/bin/bash 

if [[ $# -lt 3 ]]; then echo $0 [MRN] [YYYYMMDD] [OUTPUT DIRECTORY]; exit; fi

if [[ ! -d "$3" ]]; then mkdir -v "$3"; fi

mrn="$1"
studydate="$2"
outdir=`readlink -f $3`
dcm4che="/opt/el7/pkgs/dcm4che/dcm4che-5.11.0/bin/"

export mrn studydate outdir dcm4che

get_tag() { /opt/el7/pkgs/dcmtk/3.6.1-20161102/bin/dcmdump "$1" | grep "$2" | head -1 | awk '$0=$2' FS=[ RS=] | tr " " "_"; } 

sortd() { 
patient=`get_tag "$1" 'PatientID'`
study=`get_tag "$1" 'AccessionNumber'`
series=`get_tag "$1" 'SeriesDescription'`
seriesnum=`get_tag "$1" 'SeriesNumber'`
dpath="$outdir"/"$patient"/"$study"/"$seriesnum"_"$series"
if [[ ! "$patient" == "" ]] && [[ ! "$study" == "" ]] && [[ ! "$seriesnum" == "" ]] && [[ ! "$series" == "" ]] ; then
 if [[ ! -d "$dpath" ]]; then 
  mkdir -vp "$dpath"
  mv -v --backup=t "$1" "$dpath"
 else
  mv -v --backup=t "$1" "$dpath"
 fi 
else 
 echo missing dicom 'info', doing nothing 
fi;  
}

export -f get_tag sortd

StudyUIDs=("${StudyUIDs[@]}" `$dcm4che/findscu -c PACSDCM@pacsstor.tch.harvard.edu:104 -b RESEARCHPACS -L STUDY -M StudyRoot -mPatientID="$mrn" -mStudyDate="$studydate" -rStudyInstanceUID | grep 0020,000D | awk '$0=$2' FS=[ RS=]`)

for s in  ${StudyUIDs[@]}; do 
 $dcm4che/movescu -c PACSDCM@pacsstor.tch.harvard.edu:104 -b RESEARCHPACS --dest RESEARCHPACS -L STUDY -M StudyRoot -mStudyInstanceUID="$s"
 $dcm4che/getscu -c RESEARCHPACS@researchpacs:11112 -L STUDY -M StudyRoot -mStudyInstanceUID="$s" --directory "$outdir"
done

find "$outdir" -maxdepth 1 -type f -print | /home/ch163210/bin/parallel -j `nproc` -k sortd 

