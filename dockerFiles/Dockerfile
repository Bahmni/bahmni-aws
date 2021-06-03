FROM bahmni/bahmni-centos7
ARG rpm_version
ARG inventory_name
ARG aws_access_key
ARG aws_secret_key
ARG container_name
VOLUME ["/$container_name"]
RUN echo -e "[bahmni] \nname=Bahmni development repository for RHEL/CentOS 7\nbaseurl=http://repo.mybahmni.org/rpm/bahmni/\nenabled=1\ngpgcheck=0\n" > /etc/yum.repos.d/bahmni.repo
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install epel-release
RUN yum -y install python-pip
RUN yum -y install git
RUN yum install -y sudo openssh-server openssh-clients tar wget yum-plugin-ovl  ; yum clean all
RUN yum install -y python-setuptools
RUN pip install --upgrade pip==19.0.0
RUN yum install -y bahmni-installer-$rpm_version-*
RUN pip install --upgrade setuptools==40.0.0
RUN wget -O /etc/bahmni-installer/local https://raw.githubusercontent.com/Bahmni/bahmni-tw-playbooks/master/inventories/$inventory_name
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN echo -e "selinux_state: disabled \npostgres_version: 9.6 \ntimezone: Asia/Kolkata \nimplementation_name: default \nbahmni_support_group: bahmni_support \nbahmni_support_user: bahmni_support \nbahmni_password_hash: $1$IW4OvlrH$Kui/55oif8W3VZIrnX6jL1 \nbahmni_repo_url: http://repo.mybahmni.org/rpm/bahmni/ \nopenerp_url: https://erp-$container_name.mybahmni.org \ndocker: yes " > /etc/bahmni-installer/setup.yml
RUN sed -i "1,100 s/^/#/" /opt/bahmni-installer/bahmni-playbooks/roles/dcm4chee-oracle-java/tasks/main.yml
RUN pip uninstall -y docutils
RUN yum install -y https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.4.6.0-1.el7.ans.noarch.rpm
RUN yum install -y https://kojipkgs.fedoraproject.org//packages/zlib/1.2.11/19.fc30/x86_64/zlib-1.2.11-19.fc30.x86_64.rpm
RUN pip uninstall -y Click
RUN pip install "Click==7.0"
RUN pip install beautifulsoup4
ADD install_bahmni.sh /tmp/install_bahmni.sh
RUN chmod a+x /tmp/install_bahmni.sh
ADD db_service.sh /tmp/db_service.sh
RUN chmod a+x /tmp/db_service.sh
ENTRYPOINT ["/usr/sbin/init"]
