## Dockerfile to make "docker-abis-2025"
## This file makes a container image of docker-abis-2025
## K. Nemoto 12 Oct 2024

FROM ubuntu:22.04

# Environmental variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    RESOLUTION=1600x900x24 \
    DISPLAY=:1 \
    USER=brain \
    parts=/etc/skel/git/lin4neuro-jammy/lin4neuro-parts \
    BASE_URL="http://www.lin4neuro.net/lin4neuro/neuroimaging_software_packages"

########## Part 1. Base of Container ##########
# Install basic utilities and X11
RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       xfce4 \
       xfce4-terminal \
       xfce4-indicator-plugin  \
       xfce4-statusnotifier-plugin  \
       xfce4-screenshooter \
       elementary-xfce-icon-theme \
       gnome-icon-theme \
       librsvg2-common \
       gtk-update-icon-cache \
       tango-icon-theme \
       yaru-theme-icon \
       shimmer-themes \
       xinit \
       build-essential  \
       dkms \
       thunar-archive-plugin \
       file-roller \
       gawk \
       sed \
       xdg-utils \
       tightvncserver \
       novnc \
       websockify \
       net-tools \
       supervisor \
       x11vnc \
       xvfb \
       dbus-x11 \
       sudo \
       python3-pip \
       python3-venv \
       python3-dev \
       python3-tk \
       python3-gpg \
       tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Timezone
RUN set -ex \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

# Python
RUN set -ex \
    && python3 -m pip install --upgrade pip \
    && pip install --no-cache-dir numpy pandas pydicom gdcm dcm2bids \
       heudiconv nipype nibabel jupyter notebook \
       bash_kernel octave_kernel \
    && python3 -m bash_kernel.install

# Install utilities
RUN set -ex \
    &&  apt-get update \
    && apt-get install -y --no-install-recommends \
       less \
       iputils-ping \
       nano \
       rsync \
       locate \
       git \
       apt-utils \
       at-spi2-core \
       bc \
       curl \
       wget \
       dc \
       default-jre \
       evince \
       gedit \
       gnome-system-monitor \
       gnome-system-tools \
       imagemagick \
       rename \
       ntp \
       tree \
       unzip \
       vim  \
       zip \
       tcsh \
       baobab \
       libopenblas-base \
       apturl \
       dmz-cursor-theme \
       p7zip-full \
       gnupg \
       eog \
       meld \
       libjpeg62 \
       software-properties-common \
       fonts-noto \
       fonts-noto-cjk \
       fonts-noto-cjk-extra \
       fonts-ipafont \
       fonts-ipafont-gothic \
       fonts-ipafont-mincho \
       pigz \
       gnumeric \
       appmenu-gtk-module-common \
       appmenu-gtk2-module \
       libappmenu-gtk2-parser0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Firefox
RUN set -ex \
    && install -d -m 0755 /etc/apt/keyrings \
    && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- |\
       tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null \
    && echo '\n\
Package: *\n\
Pin: origin packages.mozilla.org\n\
Pin-Priority: 1000\n\
' | tee /etc/apt/preferences.d/mozilla \
    && apt-get update && sudo apt-get install -y firefox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Japanese environment
RUN set -ex \
    && apt-get update \
    && apt-get install -y \
       locales \
       fcitx-mozc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen ja_JP.UTF-8 
#    && mkdir -p /etc/skel/.config/autostart \ 
#    && echo '#!/bin/sh\nfcitx -d' > /etc/skel/.config/autostart/fcitx-autostart.sh \
#    && chmod +x /etc/skel/.config/autostart/fcitx-autostart.sh \
#    && echo "[Desktop Entry]\n\
#Type=Application\n\
#Name=fcitx\n\
#Exec=/etc/skel/.config/autostart/fcitx-autostart.sh\n\
#StartupNotify=false\n\
#Terminal=false\n\
#Hidden=false" > /etc/skel/.config/autostart/fcitx.desktop

ENV LANG=ja_JP.UTF-8 \
    GTK_IM_MODULE=fcitx \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx

## Install Google-chrome
#RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
# && apt install -y ./google-chrome-stable_current_amd64.deb \
# && rm google-chrome-stable_current_amd64.deb

########## End of Part 1 ##########

########## Part 2. Lin4Neuro ##########
RUN set -ex \
    && mkdir /etc/skel/git && cd /etc/skel/git \
    && git clone https://gitlab.com/kytk/lin4neuro-jammy.git \
    # Icons and Applications
    && mkdir -p /etc/skel/.local/share \ 
    && cp -r ${parts}/local/share/icons /etc/skel/.local/share/ \
    && cp -r ${parts}/local/share/applications /etc/skel/.local/share/ \
    # Customized menu
    && mkdir -p /etc/skel/.config/menus \
    && cp ${parts}/config/menus/xfce-applications.menu /etc/skel/.config/menus \
    # Customized panel, desktop, and theme
    && cp -r ${parts}/config/xfce4 /etc/skel/.config/ \
    && cp /usr/share/applications/firefox.desktop \
          /etc/skel/.config/xfce4/panel/launcher-6/ \
    && rm /etc/skel/.config/xfce4/panel/launcher-6/google-chrome.desktop \
    && rm /etc/skel/.config/xfce4/panel/launcher-6/firefox.desktop \
    # Desktop files
    && cp -r ${parts}/local/share/applications /etc/skel/.local/share/ \
    # Neuroimaging.directory
    && mkdir -p /etc/skel/.local/share/desktop-directories \
    && cp ${parts}/local/share/desktop-directories/Neuroimaging.directory \
       /etc/skel/.local/share/desktop-directories \
    # Background image and remove an unnecessary image file
    && cp ${parts}/backgrounds/deep_ocean.png /usr/share/backgrounds \
    && rm /usr/share/backgrounds/xfce/xfce-*.*p*g

COPY xfce4-panel.xml xfce4-desktop.xml \
     /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml

# .bash_aliases
COPY bash_aliases /etc/skel/.bash_aliases
COPY bash_aliases /root/.bash_aliases

########## End of Part 2 ##########

##### Part 3. Neuroimaging and related Software packages #####

RUN set -ex \
    # Install DCMTK and set up Talairach Daemon
    && apt-get update && apt-get install -y dcmtk \
    && cp -r ${parts}/tdaemon /usr/local \
    \
    # Install and configure VirtualMRI
    && cd /usr/local \
    && wget ${BASE_URL}/vmri.zip \
    && unzip vmri.zip \
    && rm vmri.zip \
    \
    # Install and configure Mango
    && cd /usr/local \
    && wget ${BASE_URL}/mango_unix.zip \
    && unzip mango_unix.zip \
    && rm mango_unix.zip \
    \
    # Install and configure MRIcroGL
    && cd /usr/local \
    && wget ${BASE_URL}/MRIcroGL_linux.zip \
    && unzip MRIcroGL_linux.zip \
    && rm MRIcroGL_linux.zip \
    \
    # Install and configure MRIcron
    && cd /usr/local \
    && wget ${BASE_URL}/MRIcron_linux.zip \
    && unzip MRIcron_linux.zip \
    && rm MRIcron_linux.zip \
    && cd mricron \
    && find . -name 'dcm2niix' -exec rm {} \; \
    && find . -name '*.bat' -exec rm {} \; \
    && find . -type d -exec chmod 755 {} \; \
    && find Resources -type f -exec chmod 644 {} \; \
    && chmod 755 /usr/local/mricron/Resources/pigz_mricron \
    \
    # Install and configure Surf-Ice
    && cd /usr/local \
    && wget ${BASE_URL}/surfice_linux.zip \
    && unzip surfice_linux.zip \
    && rm surfice_linux.zip \
    && cd Surf_Ice \
    && find . -type d -exec chmod 755 {} \; \
    && find . -type f -exec chmod 644 {} \; \
    && chmod 755 surfice* \
    && chmod 644 surfice_Linux_Installation.txt \
    \
    # Install Octave and AlizaMS
    && apt-get install -y octave \
    && mkdir -p /tmp/downloads \
    && cd /tmp/downloads \
    && wget ${BASE_URL}/alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb \
    && apt install -y /tmp/downloads/alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb \
    && rm  /tmp/downloads/alizams_1.9.10+git0.95d7909-1+1.1_amd64.deb \
    && sed -i 's/NoDisplay=true/NoDisplay=false/' \
              /etc/skel/.local/share/applications/alizams.desktop \
    \
    # Install and configure dcm2niix
    && cd /usr/local \
    && mkdir /usr/local/dcm2niix \
    && cd /tmp/downloads \
    && wget ${BASE_URL}/dcm2niix_lnx.zip \
    && unzip /tmp/downloads/dcm2niix_lnx.zip -d /usr/local/dcm2niix \
    && rm /tmp/downloads/dcm2niix_lnx.zip \
    \
    # Install and configure MRtrix3 and ANTs
    && cd /usr/local \
    && wget ${BASE_URL}/mrtrix3_jammy.zip \
    && unzip mrtrix3_jammy.zip \
    && rm mrtrix3_jammy.zip \
    && wget ${BASE_URL}/ANTs-jammy.zip \
    && unzip ANTs-jammy.zip \
    && rm ANTs-jammy.zip \
    \
    # Chris Rorden's tutorial
    && cd /etc/skel \
    && wget ${BASE_URL}/tutorial.zip \
    && unzip tutorial.zip \
    && rm tutorial.zip \
    && rm -rf __MACOSX 

RUN set -ex \
    # Install MATLAB Runtime
    && cd /tmp/ \
    && mkdir mcr_r2024b && cd mcr_r2024b \
    && wget ${BASE_URL}/MATLAB_Runtime_R2024b_glnxa64.zip \
    && unzip MATLAB_Runtime_R2024b_glnxa64.zip \
    && rm MATLAB_Runtime_R2024b_glnxa64.zip \
    && ./install -mode silent -agreeToLicense yes -destinationFolder /usr/local/MATLAB/MCR/ \
    && cd /tmp && rm -rf mcr_r2024b \
    \
    # Install and configure SPM12
    && cd /usr/local \
    && wget ${BASE_URL}/spm12_standalone_jammy_R2024b.zip \
    && unzip spm12_standalone_jammy_R2024b.zip \
    && rm spm12_standalone_jammy_R2024b.zip \
    && cd spm12_standalone \
    && chmod 755 run_spm12.sh spm12 \
    \
    # Install and configure CONN
    && cd /usr/local \
    && wget ${BASE_URL}/conn22v2407_standalone_jammy_R2024b.zip \
    && unzip conn22v2407_standalone_jammy_R2024b.zip \
    && rm conn22v2407_standalone_jammy_R2024b.zip \
    && cd conn22v2407_standalone \
    && chmod 755 run_conn.sh conn \
    \
    # Install and configure NODDI
    && cd /usr/local \
    && wget https://www.nemotos.net/l4n-abis/NODDI_jammy_R2024b.zip \
    && unzip NODDI_jammy_R2024b.zip \
    && rm NODDI_jammy_R2024b.zip \
    && cd NODDI \
    && chmod 755 NODDI run_NODDI.sh

RUN set -ex \
    # Install and configure FSL
    && cd /usr/local/ \
    && wget ${BASE_URL}/fsl-6.0.7.14-jammy.tar.gz \
    && tar -xvf fsl-6.0.7.14-jammy.tar.gz \
    && rm fsl-6.0.7.14-jammy.tar.gz \
    && sed -i 's/NoDisplay=true/NoDisplay=false/' \
              /etc/skel/.local/share/applications/fsleyes.desktop

# FSL original script
# RUN cd /tmp && \
#    wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
#    /usr/bin/python3 fslinstaller.py -d /usr/local/fsl && \

RUN set -ex \
    # Install FreeSurfer 7.4.1
    && cd /usr/local \
    && mkdir freesurfer && cd freesurfer \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      binutils libx11-dev gettext x11-apps \
      perl make csh tcsh bash file bc gzip tar \
      xorg xorg-dev xserver-xorg-video-intel \
      libncurses5 libbsd0 libc6 libc6 \
      libcom-err2 libcrypt1 libdrm2 libegl1 libexpat1 libffi7 \
      libfontconfig1 libfreetype6 libgcc-s1 libgl1 libglib2.0-0 \
      libglu1-mesa libglvnd0 libglx0 \
      libgomp1 libgssapi-krb5-2 libice6 libjpeg62 libk5crypto3 libkeyutils1 \
      libkrb5-3 libkrb5support0 libpcre3 libpng16-16 libquadmath0 libsm6 \
      libstdc++6 libuuid1 libwayland-client0 libwayland-cursor0 libx11-6 \
      libx11-xcb1 libxau6 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
      libxcb-randr0 libxcb-render-util0 libxcb-render0 libxcb-shape0 \
      libxcb-shm0 libxcb-sync1 libxcb-util1 libxcb-xfixes0 libxcb-xinerama0 \
      libxcb-xinput0 libxcb-xkb1 libxcb1 libxdmcp6 libxext6 libxft2 libxi6 \
      libxkbcommon-x11-0 libxkbcommon0 libxmu6 libxrender1 libxss1 libxt6 \
      zlib1g \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget ${BASE_URL}/freesurfer-linux-ubuntu22_amd64-7.4.1.tar.gz \
    # && wget https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/7.4.1/freesurfer-linux-ubuntu22_amd64-7.4.1.tar.gz \
    && tar -xvf freesurfer-linux-ubuntu22_amd64-7.4.1.tar.gz \
    && rm freesurfer-linux-ubuntu22_amd64-7.4.1.tar.gz \
    && mv freesurfer 7.4.1 \
    && cd /root \
    && mkdir -p freesurfer/7.4.1 \
    && cd /root/freesurfer/7.4.1 \
    && ln -s /usr/local/freesurfer/7.4.1/subjects .

# fs-scripts and kn-scripts
RUN set -ex \
    && cd /etc/skel/git \
    && git clone https://gitlab.com/kytk/fs-scripts.git \
    && git clone https://gitlab.com/kytk/kn-scripts.git \
    && mkdir /root/git \
    && cd /root/ \
    && ln -s /etc/skel/git .

# clean-up 
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

########## End of Part 3 ##########

########## Part 4. VNC ##########
# Set up VNC, create a new user, and configure software permissions
RUN set -ex \
    # Set up VNC for root
    && mkdir -p /root/.vnc \
    && echo "lin4neuro" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd \
    # Create a new user
    && useradd -m -s /bin/bash brain \
    && echo "brain:lin4neuro" | chpasswd \
    && adduser brain sudo \
    # Set up VNC for the new user
    && mkdir -p /home/brain/.vnc \
    && echo "lin4neuro" | vncpasswd -f > /home/brain/.vnc/passwd \
    && chmod 600 /home/brain/.vnc/passwd \
    && chown -R brain:brain /home/brain/.vnc \
    # Create a directory for supervisor logs
    && mkdir -p /home/brain/logs \
    && chown -R brain:brain /home/brain/logs \
    # SPM settings
    && chown -R brain:brain /usr/local/spm12_standalone \
    && cd /usr/local/spm12_standalone \
    && chmod 755 run_spm12.sh spm12 \
    # CONN settings
    && chown -R brain:brain /usr/local/conn22v2407_standalone \
    && cd /usr/local/conn22v2407_standalone \
    && chmod 755 run_conn.sh conn \
    # NODDI settings
    && chown -R brain:brain /usr/local/NODDI \
    && cd /usr/local/NODDI \
    && chmod 755 run_NODDI.sh NODDI

# Copy supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# expose port 6080
EXPOSE 6080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD nc -z localhost 6080 || exit 1

# Switch to the new user
USER brain

# Prepare FreeSurfer
RUN set -ex \
    && mkdir -p ~/freesurfer/7.4.1 \
    && cp -r /usr/local/freesurfer/7.4.1/subjects ~/freesurfer/7.4.1/

# Uncheck "Show unsafe paste dialog"
COPY terminalrc /home/brain/.config/xfce4/terminal/

# Entrypoint
COPY --chown=brain:brain docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

##### End of Part 4 ##########

