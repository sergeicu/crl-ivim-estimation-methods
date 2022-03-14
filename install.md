## Check if conda is installed 


Run `conda` in a terminal and see if it is installed.   


If not installed - see here - [link](https://engineeringfordatascience.com/posts/install_miniconda_from_the_command_line/)

## Create new conda environment 

Create:  
`conda create --name crl_ivim_estimation_tools python=3.8`

Activate:  

`conda activate crl_ivim_estimation_tools` 

## Install required python packages via pip 

`pip install -r requirements.txt`   

NB requirements.txt is a file inside this repository 

## Check if certain additional tools are available 

Check if the following are available in your Terminal: 
- `dcm2niix` 
- `averageBVals`   

DCM2niix - can be downloaded freely on the net or via conda - `conda install -c conda-forge dcm2niix`   

averageBVals - is available as a [docker image](https://github.com/sergeicu/scim_docker/) or as a centOS binary [here](https://github.com/sergeicu/scim_docker/tree/main/bin/3T)  

Alternatively - export the binaries directly from CRL filesystem:   
`PATH=$PATH:/opt/el7/pkgs/dcm2niix/dcm2niix:/fileserver/abd/bin/`
