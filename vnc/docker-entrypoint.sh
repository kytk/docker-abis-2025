#!/bin/bash

# Cleanup
rm -rf /tmp/.X* /tmp/.x*
rm -f $HOME/.vnc/*.pid $HOME/.vnc/*.log

# Set VNC password
mkdir -p $HOME/.vnc
umask 077
echo "lin4neuro" | /usr/bin/vncpasswd -f > $HOME/.vnc/passwd

# Create VNC config
cat > $HOME/.vnc/config << 'EOL'
session=xfce
geometry=1600x900
localhost=no
alwaysshared
SecurityTypes=VncAuth,TLSVnc
EOL

# Create xstartup
cat > $HOME/.vnc/xstartup << 'EOL'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Initialize dbus if needed
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

# Initialize authority file
touch $HOME/.Xauthority
xauth generate :1 . trusted

# Set XKB environment based on KEYBOARD_LAYOUT environment variable
export XKB_DEFAULT_RULES=evdev
export XKB_DEFAULT_MODEL=pc105
export XKB_DEFAULT_LAYOUT=${KEYBOARD_LAYOUT:-jp}  # Default to 'jp' if not specified
export XKB_DEFAULT_OPTIONS=terminate:ctrl_alt_bksp

# Set up basic X environment
export DISPLAY=:1
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=XFCE
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_DATA_DIRS=/usr/share

# X server options
xset s off

# Set keyboard map explicitly
setxkbmap -model $XKB_DEFAULT_MODEL -layout $XKB_DEFAULT_LAYOUT

# Cleanup any existing fcitx processes
killall -9 fcitx 2>/dev/null || true
rm -f /tmp/.fcitx-socket-* 2>/dev/null || true

# Setup fcitx environment
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export LC_CTYPE=ja_JP.UTF-8

# Wait a moment before starting fcitx
sleep 1

# Start fcitx with restart option
fcitx -r -d

# Wait for fcitx to initialize
sleep 2

# Start window manager
exec startxfce4
EOL

chmod +x $HOME/.vnc/xstartup

# Set resolution
RESOLUTION=${RESOLUTION:-1600x900}
sed -i "s|%(ENV_RESOLUTION)s|$RESOLUTION|g" /etc/supervisor/conf.d/supervisord.conf.template
cp /etc/supervisor/conf.d/supervisord.conf.template $HOME/supervisord.conf

# Create required directories and files
mkdir -p $HOME/.config
mkdir -p $HOME/.cache
mkdir -p $HOME/logs
touch $HOME/.Xauthority
chmod 600 $HOME/.Xauthority

# Copy fcitx config if needed
if [ -d "/etc/skel/.config/fcitx" ]; then
    cp -r /etc/skel/.config/fcitx $HOME/.config/
fi

# Start supervisord
exec /usr/bin/supervisord -n -c $HOME/supervisord.conf
