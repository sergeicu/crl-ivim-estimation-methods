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

## Check if certain CRL tools are available 

Try to run these commands inside Terminal to check if they are available to you: 

- `crlConvertBetweenFileFormats`
- `dcm2niix` 
- `averageBVals` 

If either binary is not available then export them inside Terminal like this: 

PATH=$PATH:/opt/el7/pkgs/crkit/2021/crkit-master/bin/:/opt/el7/pkgs/dcm2niix/dcm2niix:/fileserver/abd/bin/

and check again if either works 
