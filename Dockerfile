FROM s390x/ubuntu:16.04


WORKDIR /root/

COPY zthin_3.1.1_s390x.deb /root/

RUN dpkg -i /root/zthin_3.1.1_s390x.deb

COPY zcc.list /etc/apt/sources.list.d/

# Install required packages and remove the apt packages cache when done.
RUN apt-get update \
    && apt-get install -y s390-tools sudo openssh-server bsdmainutils uuid-runtime net-tools iputils-ping\
    && apt-get install -y --allow-unauthenticated python-zvm-sdk \
    && apt-get install -y --allow-unauthenticated apache2 libapache2-mod-wsgi supervisor

COPY zvmsdk_httpd.conf /etc/apache2/sites-available/zvmsdk_wsgi.conf
COPY zvmsdk.conf /etc/zvmsdk/zvmsdk.conf
COPY token.dat /etc/zvmsdk/token.dat

RUN a2ensite zvmsdk_wsgi \
    && chown zvmsdk:zvmsdk /etc/zvmsdk/zvmsdk.conf \
    && chown zvmsdk:zvmsdk /etc/zvmsdk/token.dat \
    && sed -i 's/zvmsdklog.log_level/zvmsdklog.LOGGER.getloglevel()/g' /usr/lib/python2.7/dist-packages/smutLayer/ReqHandle.py \
    && sed -i 's/log.log_level/log.LOGGER.getloglevel()/g' /usr/lib/python2.7/dist-packages/zvmsdk/sdkserver.py

COPY supervisor.conf /etc/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
