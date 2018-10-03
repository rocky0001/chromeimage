FROM node:7.8

ENV RemoteDisplay remotedisplay.internal.example.com:1
ENV DEBUG false
ENV HTTP_PROXY http://proxy.internal.example.com:8080
ENV HTTPS_PROXY http://proxy.internal.example.com:8080
ENV http_proxy http://proxy.internal.example.com:8080
ENV https_proxy http://proxy.internal.example.com:8080
ENV NO_PROXY ".example-support.com,.aws.example.com,.internal,169.254.169.254"

ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins
ARG VERSION=3.7



RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list
RUN apt-get update \
     && apt-get -y upgrade \
     && apt-get install -y  apt-utils  git  docker openssh-client ca-certificates openssl \
     && apt-get -t jessie-backports install -y openjdk-8-jdk
     


# chrome
ARG CHROME_VERSION="google-chrome-stable"
RUN apt-get update && \
    apt-get -y install wget unzip locales  xvfb  && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
      && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
      && apt-get update -qqy \
      && apt-get -qqy install \
        ${CHROME_VERSION:-google-chrome-stable} \
      && rm /etc/apt/sources.list.d/google-chrome.list 
     
#COPY chrome_launcher.sh /opt/google/chrome/google-chrome
#RUN chmod +x /opt/google/chrome/google-chrome


# chrome driver
ARG CHROME_DRIVER_VERSION=2.29
RUN wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

RUN npm install yarn
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN mkdir /root/.ssh
RUN echo 'github.internal.example.com,172.0.0.1 ecdsa-sha2-nistp256 XXXXXXX' >> /root/.ssh/known_hosts

#Install npm-link-shared
RUN npm install npm-link-shared -g

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

#Clean up
RUN apt-get autoclean && \
    apt-get autoremove
RUN rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*


USER jenkins
ENV SCREEN_WIDTH 1360
ENV SCREEN_HEIGHT 1020
ENV SCREEN_DEPTH 24
ENV DISPLAY :99.0

RUN mkdir /home/jenkins/.jenkins
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins


ENTRYPOINT ["entrypoint.sh"]