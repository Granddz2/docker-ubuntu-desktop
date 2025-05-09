FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# تحديث النظام وتثبيت الحزم الأساسية
RUN apt update -y && apt install --no-install-recommends -y \
    cinnamon-desktop-environment \
    tigervnc-standalone-server \
    novnc websockify \
    sudo xterm init systemd snapd \
    vim net-tools curl wget git tzdata dbus-x11 \
    x11-utils x11-xserver-utils x11-apps \
    software-properties-common

# إعداد Firefox من PPA
RUN add-apt-repository ppa:mozillateam/ppa -y
RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox \
 && echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox \
 && echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox \
 && echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox \
 && apt update -y && apt install -y firefox

# إضافة بعض الأيقونات لتحسين الواجهة
RUN apt install -y xubuntu-icon-theme

# إنشاء ملف Xauthority
RUN touch /root/.Xauthority

# فتح المنافذ
EXPOSE 5901
EXPOSE 6080

# تشغيل VNC + Websockify
CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
openssl req -new -subj \"/C=JP\" -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
tail -f /dev/null"
