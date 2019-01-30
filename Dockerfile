#測試 push 變更
# 安裝環境與套件
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
RUN yum -y install sudo
RUN cd /tmp && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# 拉測試專案
RUN git clone https://github.com/blaze0207/cloud-build-test.git

# 建立 user 並授與 sudo
RUN adduser hahn
RUN usermod -aG wheel hahn

# 將專案改變擁有者權限
RUN chown hahn -R /cloud-build-test
USER hahn

# 這邊根據每個人的狀況決定，因為我本機是 php7， 所以會有版本的問題，這邊刪掉用 php5 的環境去安裝
RUN rm -f /cloud-build-test/composer.lock
RUN rm -rf /cloud-build-test/vendor

# 進入資料夾
WORKDIR /cloud-build-test

# 開始安裝
RUN composer install

# 初始化環境變數
RUN cp .env.example .env
RUN php artisan key:generate

# 執行單元測試
CMD ["/cloud-build-test/vendor/bin/phpunit"]
