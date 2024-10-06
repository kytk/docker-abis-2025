## Dockerfile to make "docker-abis-2025"
## This file makes a container image of docker-abis-2025
## K. Nemoto 06 Oct 2024

FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic utilities and X11
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    xfce4 \
    xfce4-terminal \
    xfce4-indicator-plugin  \
#    xfce4-clipman \
#    xfce4-clipman-plugin \
    xfce4-statusnotifier-plugin  \
#    xfce4-power-manager-plugins \
    xfce4-screenshooter \
    lightdm \
    lightdm-gtk-greeter \
    lightdm-gtk-greeter-settings \
    shimmer-themes \
#    network-manager-gnome \
    xinit \
    build-essential  \
    dkms \
    thunar-archive-plugin \
#    file-roller \
    gawk \
    xdg-utils \
    tightvncserver \
    novnc \
    websockify \
    net-tools \
    supervisor \
    x11vnc \
    xvfb \
    dbus-x11 \
    sudo

# Python
RUN apt-get install -y python3-pip python3-venv python3-dev python3-tk \
    python3-gpg 

RUN python3 -m pip install --upgrade pip
RUN pip install numpy pandas pydicom gdcm dcm2bids heudiconv \
     nipype nibabel jupyter notebook bash_kernel octave_kernel && \
    python3 -m bash_kernel.install

# Install utilities
RUN apt-get install -y \
    git \
    apt-utils \
    at-spi2-core \
    bc \
#    byobu \
    curl \
    wget \
    dc \
    default-jre \
    evince \
#    exfatprogs \
    gedit \
    gnome-system-monitor \
    gnome-system-tools \
#    gparted \
    imagemagick \
    rename \
    ntp \
#    system-config-printer \
    tree \
    unzip \
    vim  \
    zip \
    tcsh \
    baobab \
#    bleachbit \
    libopenblas-base \
    cups \
    apturl \
    dmz-cursor-theme \
#    chntpw \
#    gddrescue \
    p7zip-full \
    gnupg \
    eog \
    meld \
    libjpeg62 \
    software-properties-common \
    fonts-noto \
#    mupdf \
#    mupdf-tools \
    pigz \
#    ristretto \
#    pinta \
#    libreoffice
    gnumeric
 
# Install Google-chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install -y ./google-chrome-stable_current_amd64.deb
RUN rm google-chrome-stable_current_amd64.deb

##### Lin4Neuro #####
RUN mkdir /etc/skel/git && cd /etc/skel/git && \
    git clone https://gitlab.com/kytk/lin4neuro-jammy.git
ENV parts=/etc/skel/git/lin4neuro-jammy/lin4neuro-parts

# Icons and Applications
RUN mkdir -p /etc/skel/.local/share && \ 
    cp -r ${parts}/local/share/icons /etc/skel/.local/share/ && \
    cp -r ${parts}/local/share/applications /etc/skel/.local/share/

# Customized menu
RUN mkdir -p /etc/skel/.config/menus && \
    cp ${parts}/config/menus/xfce-applications.menu /etc/skel/.config/menus

# Customized panel, desktop, and theme
RUN cp -r ${parts}/config/xfce4 /etc/skel/.config/

# Desktop files
RUN cp -r ${parts}/local/share/applications /etc/skel/.local/share/


# Neuroimaging.directory
RUN mkdir -p /etc/skel/.local/share/desktop-directories && \
    cp ${parts}/local/share/desktop-directories/Neuroimaging.directory \
       /etc/skel/.local/share/desktop-directories

# Background image and remove an unnecessary image file
RUN cp ${parts}/backgrounds/deep_ocean.png /usr/share/backgrounds && \
    rm /usr/share/backgrounds/xfce/xfce-*.*p*g
COPY xfce4-desktop.xml /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/

# Modified lightdm-gtk-greeter.conf
RUN mkdir -p /usr/share/lightdm/lightdm-gtk-greeter.conf.d && \
    cp ${parts}/lightdm/lightdm-gtk-greeter.conf.d/01_ubuntu.conf /usr/share/lightdm/lightdm-gtk-greeter.conf.d

# Auto-login
RUN mkdir -p /usr/share/lightdm/lightdm.conf.d && \
    cp ${parts}/lightdm/lightdm.conf.d/10-ubuntu.conf \
 /usr/share/lightdm/lightdm.conf.d

# Clean packages
RUN apt-get -y autoremove

# alias
RUN echo "alias open='xdg-open &> /dev/null'" >> /etc/skel/.bash_aliases

# Deactivate screensaver
RUN echo 'xset s off' >> /etc/skel/.xsession

##### Lin4Neuro settings end #####

##### Neuroimaging and related Software packages #####

# DCMTK
RUN apt-get install -y dcmtk

# Talairach Daemon
RUN cp -r ${parts}/tdaemon /usr/local && \
    echo '' >> /etc/skel/.bash_aliases && \
    echo '#tdaemon' >> /etc/skel/.bash_aliases && \
    echo "alias tdaemon='java -jar /usr/local/tdaemon/talairach.jar'" >> /etc/skel/.bash_aliases

## VirtualMRI
#RUN cd /usr/local && \
#    wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/vmri.zip && \
#    unzip vmri.zip && rm vmri.zip

# Mango
RUN cd /usr/local && \
    wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/mango_unix.zip && \
    unzip mango_unix.zip && rm mango_unix.zip && \
    echo '' >> /etc/skel/.bash_aliases && \
    echo '#Mango' >> /etc/skel/.bash_aliases && \
    echo 'export PATH=$PATH:/usr/local/Mango' >> /etc/skel/.bash_aliases

# MRIcroGL
RUN cd /usr/local &&  \
    wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/MRIcroGL_linux.zip && unzip MRIcroGL_linux.zip && rm MRIcroGL_linux.zip && \
    echo '' >> /etc/skel/.bash_aliases && \
    echo '#MRIcroGL' >> /etc/skel/.bash_aliases && \
    echo 'export PATH=$PATH:/usr/local/MRIcroGL' >> /etc/skel/.bash_aliases && \
    echo 'export PATH=$PATH:/usr/local/MRIcroGL/Resources' >> /etc/skel/.bash_aliases

# MRIcron
RUN cd /usr/local && wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/MRIcron_linux.zip && \
    unzip MRIcron_linux.zip && rm MRIcron_linux.zip && \
    cd mricron && \
    find . -name 'dcm2niix' -exec rm {} \; && \
    find . -name '*.bat' -exec rm {} \; && \
    find . -type d -exec chmod 755 {} \; && \
    find Resources -type f -exec chmod 644 {} \; && \
    chmod 755 /usr/local/mricron/Resources/pigz_mricron && \
    echo '' >> /etc/skel/.bash_aliases && \
    echo '#MRIcron' >> /etc/skel/.bash_aliases && \
    echo 'export PATH=$PATH:/usr/local/mricron' >> /etc/skel/.bash_aliases

# Surf-Ice
RUN cd /usr/local && wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/surfice_linux.zip && \
    unzip surfice_linux.zip && rm surfice_linux.zip && \
    cd Surf_Ice && \
    find . -type d -exec chmod 755 {} \; && \
    find . -type f -exec chmod 644 {} \; && \
    chmod 755 surfice* && \
    chmod 644 surfice_Linux_Installation.txt && \
    echo '' >> /etc/skel/.bash_aliases && \
    echo '#Surf_Ice' >> /etc/skel/.bash_aliases && \
    echo 'export PATH=$PATH:/usr/local/Surf_Ice' >> /etc/skel/.bash_aliases

# FSL
RUN cd /tmp && \
    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
    /usr/bin/python3 fslinstaller.py -d /usr/local/fsl && \
echo '\n\
# FSL Setup\n\
FSLDIR=/usr/local/fsl\n\
PATH=${FSLDIR}/share/fsl/bin:${PATH}\n\
export FSLDIR PATH\n\
. ${FSLDIR}/etc/fslconf/fsl.sh' >> /etc/skel/.bash_aliases && \
sed -i 's/NoDisplay=true/NoDisplay=false/' /etc/skel/.local/share/applications/fsleyes.desktop

# Octave
RUN apt-get install -y octave

# AlizaMS
RUN cd /tmp && \
wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/alizams_1.9.5+git0.c3ce1bd-1+1.1_amd64.deb && \
apt install -y ./alizams_1.9.5+git0.c3ce1bd-1+1.1_amd64.deb && \
rm alizams_1.9.5+git0.c3ce1bd-1+1.1_amd64.deb && \
sed -i 's/NoDisplay=true/NoDisplay=false/' /etc/skel/.local/share/applications/alizams.desktop

# dcm2niix
RUN cd /usr/local && \
mkdir /usr/local/dcm2niix && \
wget https://github.com/rordenlab/dcm2niix/releases/download/v1.0.20240202/dcm2niix_lnx.zip && \
unzip dcm2niix_lnx.zip -d /usr/local/dcm2niix && rm dcm2niix_lnx.zip && \
echo '' >> /etc/skel/.bash_aliases && \
echo '# dcm2niix' >> /etc/skel/.bash_aliases && \
echo 'export PATH=/usr/local/dcm2niix:$PATH' >> /etc/skel/.bash_aliases

# MRtrix3
RUN \
# apt-get install -y \
#    g++ \
#    libeigen3-dev \
#    zlib1g-dev \
#    libqt5opengl5-dev \
#    libqt5svg5-dev \
#    libgl1-mesa-dev \
#    libfftw3-dev \
#    libtiff5-dev \
#    libpng-dev && \
cd /usr/local && \
wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/mrtrix3_jammy.zip && \
unzip mrtrix3_jammy.zip && \
echo '\n\
# MRtrix3\n\
export PATH=$PATH:/usr/local/mrtrix3/bin' >> /etc/skel/.bash_aliases

# ANTs
RUN cd /usr/local && \
wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/ANTs-jammy.zip && \
unzip ANTs-jammy.zip && \
echo '\n\
#ANTs\n\
export ANTSPATH=/usr/local/ANTs/bin\n\
export PATH=$PATH:$ANTSPATH' >> /etc/skel/.bash_aliases

# MCR
RUN cd /tmp/ && \
mkdir mcr_v913 && cd mcr_v913 && \
wget https://ssd.mathworks.com/supportfiles/downloads/R2022b/Release/10/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2022b_Update_10_glnxa64.zip && \
unzip MATLAB_Runtime_R2022b_Update_10_glnxa64.zip && \
./install -mode silent -agreeToLicense yes \
    -destinationFolder /usr/local/MATLAB/MCR/ && \
cd /tmp && rm -rf mcr_v913

# NODDI
RUN cd /usr/local && \
wget https://www.nemotos.net/l4n-abis/NODDI_linux.zip && \
unzip NODDI_linux.zip && rm NODDI_linux.zip && \
echo '\n\
# NODDI\n\
export PATH=$PATH:/usr/local/NODDI' >> /etc/skel/.bash_aliases

# SPM12
RUN cd /usr/local && \
wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/spm12_standalone_jammy_R2022b.zip && \
unzip spm12_standalone_jammy_R2022b.zip && \
rm spm12_standalone_jammy_R2022b.zip && \
cd spm12_standalone && \
chmod 755 run_spm12.sh spm12 && \
echo '' >> /etc/skel/.bash_aliases && \
echo '#SPM12 standalone' >> /etc/skel/.bash_aliases && \
echo "alias spm='/usr/local/spm12_standalone/run_spm12.sh /usr/local/MATLAB/MCR/R2022b/'" >> /etc/skel/.bash_aliases

# CONN 22v2407
RUN cd /usr/local && \
wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/conn22v2407_standalone.zip && \
unzip conn22v2407_standalone.zip && rm conn22v2407_standalone.zip && \
echo '' >> /etc/skel/.bash_aliases && \
echo '#CONN22v2407 standalone' >> /etc/skel/.bash_aliases && \
echo "alias conn='/usr/local/conn22v2407_standalone/run_conn.sh /usr/local/MATLAB/MCR/R2022b/'" >> /etc/skel/.bash_aliases

# FreeSurfer 7.4.1
# Install dependencies
RUN cd /usr/local && \
mkdir freesurfer && cd freesurfer && \
apt install -y binutils libx11-dev gettext x11-apps \
  perl make csh tcsh bash file bc gzip tar \
  xorg xorg-dev xserver-xorg-video-intel libncurses5 libbsd0 libc6 libc6 \
  libcom-err2 libcrypt1 libdrm2 libegl1 libexpat1 libffi7 libfontconfig1 \
  libfreetype6 libgcc-s1 libgl1 libglib2.0-0 libglu1-mesa libglvnd0 libglx0 \
  libgomp1 libgssapi-krb5-2 libice6 libjpeg62 libk5crypto3 libkeyutils1 \
  libkrb5-3 libkrb5support0 libpcre3 libpng16-16 libquadmath0 libsm6 \
  libstdc++6 libuuid1 libwayland-client0 libwayland-cursor0 libx11-6 \
  libx11-xcb1 libxau6 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
  libxcb-randr0 libxcb-render-util0 libxcb-render0 libxcb-shape0 \
  libxcb-shm0 libxcb-sync1 libxcb-util1 libxcb-xfixes0 libxcb-xinerama0 \
  libxcb-xinput0 libxcb-xkb1 libxcb1 libxdmcp6 libxext6 libxft2 libxi6 \
  libxkbcommon-x11-0 libxkbcommon0 libxmu6 libxrender1 libxss1 libxt6 \
  zlib1g && \
wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.4.1/freesurfer-linux-ubuntu22_amd64-7.4.1.tar.gz && \
tar -xvf freesurfer-linux-ubuntu22_amd64-7.4.1.tar.gz && \
rm freesurfer-linux-ubuntu22_amd64-7.4.1.tar.gz && \
mv freesurfer 7.4.1 && \
echo '\n\
#FreeSurfer 7.4.1\n\
export SUBJECTS_DIR=~/freesurfer/7.4.1/subjects\n\
export FREESURFER_HOME=/usr/local/freesurfer/7.4.1\n\
export FS_LICENSE=~/share/license.txt\n\
source $FREESURFER_HOME/SetUpFreeSurfer.sh' >> /etc/skel/.bash_aliases

# fs-scripts
RUN cd /etc/skel/git && \
git clone https://gitlab.com/kytk/fs-scripts.git && \
echo '\n\
# fs-scripts \n\
export PATH=$PATH:~/git/fs-scripts' >> /etc/skel/.bash_aliases

# kn-scripts
RUN cd /etc/skel/git && \
git clone https://gitlab.com/kytk/kn-scripts.git && \
echo '\n\
# kn-scripts \n\
export PATH=$PATH:~/git/kn-scripts' >> /etc/skel/.bash_aliases


##### End of Neuroimaging and Related Software packages #####

# Set up VNC
RUN mkdir -p /root/.vnc && \
    echo "lin4neuro" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Create a new user
RUN useradd -m -s /bin/bash brain && \
    echo "brain:lin4neuro" | chpasswd && \
    adduser brain sudo

# SPM settings
RUN chown -R brain:brain /usr/local/spm12_standalone && \
cd /usr/local/spm12_standalone && \
chmod 755 run_spm12.sh spm12

# CONN settings
RUN chown -R brain:brain /usr/local/conn22v2407_standalone

# Set up VNC for the new user
RUN mkdir -p /home/brain/.vnc && \
    echo "lin4neuro" | vncpasswd -f > /home/brain/.vnc/passwd && \
    chmod 600 /home/brain/.vnc/passwd && \
    chown -R brain:brain /home/brain/.vnc

# Create a directory for supervisor logs
RUN mkdir -p /home/brain/logs && \
    chown -R brain:brain /home/brain/logs


# Copy supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ENV DISPLAY=:1

EXPOSE 6080

# Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh


# Switch to the new user
USER brain
ENV USER=brain

RUN mkdir -p ~/freesurfer/7.4.1 && \
cp -r /usr/local/freesurfer/7.4.1/subjects ~/freesurfer/7.4.1/


#CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
