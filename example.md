WARNING: our example data does NOT contain DICOM files due to PHI. Hence, we ignore the first step of the pipeline ('download_and_convert_dicoms'). If you have access to CRL network - do this step [like this](preprocessing/download_and_convert_dicoms.sh)

## Using python and binaries directly 

NB: please note that you followed instructions here [install.md](install.md)

```

cd example_data 

subject=f0944s1_1

python process_nifti.py -f ${subject}.nii

python geometric_averages.py --d $PWD --noabsolute

```


## Using docker 


### Inside docker 
```
cd example_data 

# pull docker image
version=latest
image=sergeicu/scim_preprocessing:$version
docker pull $image

# enter docker 
docker run -it --rm -v $PWD:/data/ $image /bin/bash 

# process
subject=f0944s1_1
python process_nifti.py -f /data/${subject}.nii
python geometric_averages.py --d /data/ --noabsolute

# set permissions 
chmod -R ugu+rw /data/

# exit docker 
exit

```

## Notes
- `chmod -R ugo+rw` is necessary command inside docker else you won't be able to delete / move your data
