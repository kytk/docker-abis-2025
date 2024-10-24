#alias for xdg-open
alias open='xdg-open &> /dev/null'

#shopt
shopt -s direxpand
shopt -s autocd

#xset
xset r rate

# Mango
export PATH=$PATH:/usr/local/Mango

# MRIcroGL
export PATH=/usr/local/MRIcroGL:$PATH
export PATH=/usr/local/MRIcroGL/Resources:$PATH

# MRIcron
export PATH=$PATH:/usr/local/mricron

# Surf_Ice
export PATH=$PATH:/usr/local/Surf_Ice

# Talairach daemon
alias tdaemon='java -jar /usr/local/tdaemon/talairach.jar'

#ANTs
export ANTSPATH=/usr/local/ANTs/bin
export PATH=$PATH:$ANTSPATH

# MRtrix3
export PATH=$PATH:/usr/local/mrtrix3/bin

# PATH for kn-scripts
export PATH=$PATH:/home/kiyotaka/git/kn-scripts

#PATH for fs-scripts
export PATH=$PATH:/home/kiyotaka/git/fs-scripts

# dcm2niix
export PATH=/usr/local/dcm2niix:$PATH

#SPM12 standalone
alias spm='/usr/local/spm12_standalone/run_spm12.sh /usr/local/MATLAB/MCR/R2024b 2>/dev/null'

#conn22v2407 standalone
alias conn='/usr/local/conn22v2407_standalone/run_conn.sh /usr/local/MATLAB/MCR/R2024b 2>/dev/null'

#NODDI standalone
alias noddi='/usr/local/NODDI/run_NODDI.sh /usr/local/MATLAB/MCR/R2024b 2>/dev/null'

#FreeSurfer 7.4.1
export SUBJECTS_DIR=~/freesurfer/7.4.1/subjects
export FREESURFER_HOME=/usr/local/freesurfer/7.4.1
export FS_LICENSE=~/share/license.txt
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# FSL Setup
FSLDIR=/usr/local/fsl
PATH=${FSLDIR}/share/fsl/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

# fs-scripts 
PATH=$PATH:/home/brain/git/fs-scripts

# kn-scripts 
PATH=$PATH:/home/brain/git/kn-scripts

