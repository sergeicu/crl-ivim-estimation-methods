### 
# execute on a server via SSH 
### 

# WARNINGS: 
# - we strongly advise to execute these commands on a CRL server with enough CPUs and memory via ssh
# - we had previously attempted to write a .m function that would compute all slices at once on a CRL server. However this often causes the process to run out of memory. Therefore we wrote a simple routine to process multiple slices in separate matlab calls (without the need to open matlab manually)

# ssh 
ssh <machine>

# init 
bvalsFileNames_textfile=
savedir=$(dirname $bvalsFileNames_textfile)/output/
mkdir $savedir
slice_start=40
slice_end=45

# process 
codedir=/fileserver/fastscratch/serge/ivim_matlab/
filedir=$(dirname $bvalsFileNames_textfile)
cd $filedir
cp -r ${codedir}/* .
for slice in $(seq $slice_start $slice_end)
do
    echo "Computing slice $slice"
    matlab -nodisplay -nosplash -nodesktop -r "process_ivim_whole_slice('$bvalsFileNames_textfile', '$savedir', $slice);exit" -logfile $savedir/log_sl${slice}.txt
done



# merge final files 
cd $savedir
#TBC - not completed yet


###
# list of CRL machines 
### 
https://docs.google.com/spreadsheets/d/1JiM8Ef2Qg0oSVbDzldjbk7uTFKU0MNKOzaZck_QgzAY/edit

