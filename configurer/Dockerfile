FROM ubuntu

RUN apt-get update && \
    apt-get install -y software-properties-common apt-utils locales tzdata

RUN echo "tzdata tzdata/Areas select Europe" > timezone.txt
RUN echo "tzdata tzdata/Zones/Europe select Rome" >> timezone.txt
RUN debconf-set-selections timezone.txt
RUN rm /etc/timezone
RUN rm /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update && apt-get install -y \
    curl \
    postgresql postgresql-contrib \
    && curl -sSL https://get.docker.com/ | sh

COPY ./start.sh /usr/src/
COPY ./cleanup.sh /usr/src/
COPY ./json/* /usr/src/
COPY ./sql/* /usr/src/
RUN chmod +x /usr/src/start.sh
RUN chmod +x /usr/src/cleanup.sh
CMD ["bash", "/usr/src/start.sh"]