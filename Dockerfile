FROM node:5.6-slim

# METEOR
RUN curl https://install.meteor.com/ | sh

# CHIMP
# Dependency: Oracle Java 8
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Dependency: Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update
RUN apt-get install -y google-chrome-stable libexif-dev

# Dependency: Git
RUN apt-get install -y git-core

# Dependency: xvfb (fake screen)
RUN apt-get install -y xvfb

# X11VNC
RUN apt-get install -y x11vnc
RUN mkdir ~/.vnc
RUN x11vnc -storepasswd chimpatee ~/.vnc/passwd

WORKDIR /opt/chimp

# Install chimp's NPM dependencies
COPY package.json /opt/chimp/
RUN npm install

# Cache Chimp's Auto-Installed Dependencies
RUN node_modules/.bin/chimp --path=git-hooks

COPY .scripts/start.js /opt/chimp/.scripts/
COPY .scripts/headless-start.js /opt/chimp/.scripts/
COPY data /opt/chimp/data/

CMD ["node", ".scripts/headless-start.js"]
