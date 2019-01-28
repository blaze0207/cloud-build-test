FROM centos:6

RUN yum -y update && \
    yum -y install httpd cronie git wget epel-release curl && \
    yum clean all
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && \
    wget https://centos6.iuscommunity.org/ius-release.rpm && \
    rpm -Uvh ius-release*.rpm && \
    yum -y update && \
    yum -y install php56u php56u-gd php56u-mysql php56u-mcrypt php56u-openssl php56u-pdo php56u-mbstring php56u-tokenizer php56u-xml php56u-soap mod_ssl openssl && \
    yum -y clean all
RUN yum -y install php56u-devel gcc
RUN yum -y install openssl-devel
RUN pecl install mongodb
RUN curl https://bootstrap.pypa.io/2.6/get-pip.py -o get-pip.py && \
    python get-pip.py
RUN pip install supervisor && \
    pip install setuptools --upgrade
RUN yum -y install python36u python36u-pip gcc python36u-devel && \
    pip3.6 install pip setuptools --upgrade
RUN pip3.6 install scrapy
RUN cd /tmp && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer
RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Taipei /etc/localtime

RUN yum -y install sudo

RUN git clone https://github.com/blaze0207/cloud-build-test.git

RUN adduser hahn
RUN usermod -aG wheel hahn

RUN chown hahn -R /cloud-build-test
USER hahn

RUN rm -f /cloud-build-test/composer.lock
RUN rm -rf /cloud-build-test/vendor

WORKDIR /cloud-build-test

RUN composer install

RUN cp .env.example .env
RUN php artisan key:generate

CMD ["/cloud-build-test/vendor/bin/phpunit"]
# CMD ["/cloudbuild.sh"]
