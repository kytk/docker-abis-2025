## Dockerfile to make "docker-l4n-jammy"
## This file makes a container image of docker-lin4neuro
## K. Nemoto 29 Sep 2024

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install basic utilities and X11
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    xfce4 \
    xfce4-terminal \
    xfce4-indicator-plugin  \
    xfce4-clipman \
    xfce4-clipman-plugin \
    xfce4-statusnotifier-plugin  \
    xfce4-power-manager-plugins \
    xfce4-screenshooter \
    lightdm \
    lightdm-gtk-greeter \
    lightdm-gtk-greeter-settings \
    shimmer-themes \
    network-manager-gnome \
    xinit \
    build-essential  \
    dkms \
    thunar-archive-plugin \
    file-roller \
    gawk \
    xdg-utils \
    tightvncserver \
    novnc \
    websockify \
    net-tools \
    curl \
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
     nipype nibabel jupyter notebook bash_kernel && \
    python3 -m bash_kernel.install

# Install utilities
RUN apt-get install -y \
    git \
    apt-utils \
    at-spi2-core \
    bc \
    byobu \
    curl \
    wget \
    dc \
    default-jre \
    evince \
    exfatprogs \
    gedit \
    gnome-system-monitor \
    gnome-system-tools \
    gparted \
    imagemagick \
    rename \
    ntp \
    system-config-printer \
    tree \
    unzip \
    update-manager \
    vim  \
    zip \
    tcsh \
    baobab \
    bleachbit \
    libopenblas-base \
    cups \
    apturl \
    dmz-cursor-theme \
    chntpw \
    gddrescue \
    p7zip-full \
    gnupg \
    eog \
    meld \
    libjpeg62 \
    software-properties-common \
    fonts-noto \
    mupdf \
    mupdf-tools \
    pigz \
    ristretto \
    pinta \
    libreoffice
 
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

# Neuroimaging.directory
RUN mkdir -p /etc/skel/.local/share/desktop-directories && \
    cp ${parts}/local/share/desktop-directories/Neuroimaging.directory \
       /etc/skel/.local/share/desktop-directories

# Background image and remove an unnecessary image file
RUN cp ${parts}/backgrounds/deep_ocean.png /usr/share/backgrounds && \
    rm /usr/share/backgrounds/xfce/xfce-*.png && \
    ln -s /usr/share/backgrounds/deep_ocean.png /usr/share/backgrounds/xfce/xfce-stripes.png

# Customized panel, desktop, and theme
RUN cp -r ${parts}/config/xfce4 /etc/skel/.config

RUN echo "alias open='xdg-open &> /dev/null'" >> /etc/skel/.bash_aliases

##### Lin4Neuro settings end #####

##### Neuroimaging and related Software packages #####

# DCMTK
RUN apt-get install -y dcmtk

# Talairach Daemon
RUN cp -r ${parts}/tdaemon /usr/local && \
    echo '' >> /etc/skel/.bash_aliases && \
    echo '#tdaemon' >> /etc/skel/.bash_aliases && \
    echo "alias tdaemon='java -jar /usr/local/tdaemon/talairach.jar'" >> /etc/skel/.bash_aliases

# VirtualMRI
RUN cd /usr/local && \
    wget http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages/vmri.zip && \
    unzip vmri.zip && rm vmri.zip

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
    /usr/bin/python3 fslinstaller.py -d /usr/local/fsl

# FSL profile setting
RUN echo '\n\
# FSL Setup\n\
FSLDIR=/usr/local/fsl\n\
PATH=${FSLDIR}/share/fsl/bin:${PATH}\n\
export FSLDIR PATH\n\
. ${FSLDIR}/etc/fslconf/fsl.sh' >> /etc/skel/.bash_aliases

# VS code
RUN cd /tmp && \
curl https://packages.microsoft.com/keys/microsoft.asc -o vscode.asc && \
gpg --output /usr/share/keyrings/vscode.gpg --dearmor vscode.asc && \
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main" | tee /etc/apt/sources.list.d/vscode.list && \
apt-get update && apt-get install -y code

##### End of Neuroimaging and Related Software packages #####



# Set up VNC
RUN mkdir -p /root/.vnc && \
    echo "lin4neuro" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Create a new user
RUN useradd -m -s /bin/bash brain && \
    echo "brain:lin4neuro" | chpasswd && \
    adduser brain sudo

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

#CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
