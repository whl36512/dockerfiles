FROM local/r8-systemd  AS baseos
ENV container docker

#RUN yum groups mark convert

RUN echo 'sslverify=false' >> /etc/yum.conf

#RUN yum clean all; yum update -y ; yum -y install passwd; echo root | passwd --stdin root ; yum -y install httpd openssh-server openssh-clients initscripts;  echo 'set -o vi' >> /etc/profile; chkconfig sshd on ; chkconfig httpd on ;echo 'export TERM=linux' >> /etc/profile 

RUN yum clean all; yum update -y ; \
    yum install -y epel-release  
RUN yum install -y httpd mod_ssl openssh-server openssh-clients initscripts sudo  passwd rsyslog cronie netcat which procps net-tools iproute sysstat libmemcached screen; \
    echo 'set -o vi; export EDITOR=vi; export HISTTIMEFORMAT="[%a %b %d %T %Y] "' >> /etc/profile; \
    echo 'export TERM=linux' >> /etc/profile ; \
    chkconfig sshd on ; chkconfig httpd on ; \
    systemctl enable rsyslog; systemctl enable crond ; \
    mkdir /root/.ssh; chmod 600 /root/.ssh; ls -l /root/.ssh ; \
    mkdir /mnt/repo ; chmod 777 /mnt/repo

# install gcc, etc
RUN yum group install -y "Development Tools" 
# get rid of message 'Failed to set locale, defaulting to C.UTF-8'. Manually run localectl set-locale LANG=en_US.UTF-8 after login
RUN dnf install -y glibc-langpack-en


# at host shell, do 
# ssh-copy-id localhost
# to generate authorized_keys
# and do
# cp -r ~/.ssh ssh
WORKDIR /root/.ssh
ADD --chmod=600 ssh/*  ./

#FROM baseos AS base_git

# endpoint is for installation of latest git
RUN yum -y install https://packages.endpointdev.com/rhel/8/main/x86_64 ; yum install -y git
#RUN git config --global user.email "whl36512@gmail.com"
#RUN git config --global user.name "whl36512"

#FROM base_git AS base_ansible

# install miniconda
ENV CONDA_DIR /opt/conda
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh --output ~/miniconda.sh && /bin/bash ~/miniconda.sh -b -p /opt/conda ; /opt/conda/bin/conda init
ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda install -c conda-forge ansible 
RUN conda update -c conda-forge jinja2  # must update jinja2 for ansible to work

#RUN yum install -y yum-utils
#RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
#RUN yum -y install vault

RUN echo 'set -o vi' >> /etc/bashrc
RUN echo 'export JAVA_HOME=/usr/lib/jvm/zulu8' >> /etc/bashrc
RUN echo 'export GRADLE_USER_HOME=~/.gradle' >> /etc/bashrc
RUN echo 'export PATH=/opt/conda/bin:/mnt/c/weihan/dl/flink-1.9.3/bin:/usr/local/bin:$PATH' >> /etc/bashrc
#RUN echo 'export KUBECONFIG=/etc/kube/config/admin.conf.from.bigkum201v.prd.chi.accertify.net.20220708' >> /etc/bashrc
RUN echo 'export KUBECONFIG=/mnt/c/weihan/config/kube/admin.conf.from.bigkum201v.prd.chi.accertify.net.20220708' >> /etc/bashrc
RUN echo 'export HISTSIZE=100000' >> /etc/bashrc

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl";  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl ; rm kubectl
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# install docker to run docker in docker
RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
RUN yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#RUN yum install -y wget
# curl downloaded 0 size file. wget works
#RUN wget https://github.com/stern/stern/releases/download/v1.25.0/stern_1.25.0_linux_amd64.tar.gz
#RUN tar  -xvf stern_1.25.0_linux_amd64.tar.gz

# these commands cause build to stuck at exporting layers.  Run these commands after login as root to the container
#RUN groupadd -g 1162600547 wlin ; adduser -u 1162600547 -g 1162600547 wlin ; usermod -u 1162600547 wlin ; groupmod -g 1162600547 wlin ; cp -rf /root/.ssh ~wlin/. ; chown -R wlin:wlin ~wlin ; chmod -R 700 ~wlin/.ssh   \


# a ansible play book will install the following files
#ADD --chmod=644 files/gradle.properties ~/.gradle/.
#ADD --chmod=644 files/gitignore ~/.gitignore
#ADD --chmod=644 files/gitconfig ~/.gitconfig


#FROM scratch
#COPY --from=baseos / /

EXPOSE 22
EXPOSE 80

VOLUME [ "/sys/fs/cgroup" ]
# ENTRYPOINT will always run. CMD will be appended to ENTRYPOINT. CMD can be replaced by command line parameter when 'docker run'
ENTRYPOINT /usr/sbin/init
#CMD ["/usr/sbin/init"]

# ------------------------------------------------------------------
#DOCKER_BUILDKIT=1 docker build -f rocky-basic.dockerfile --rm -t local/r8-basic . 
# use docker's default bridge network 
# the container cannot be pinged from other hosts
# the container can ping outside world
# cannot set ip address
# to ssh to the container from other hosts, 22 must be mapped 
# docker run --privileged --rm --name r8 --hostname r8  --network=bridge  -p10022:22 -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ~/repo:/mnt/repo:ro  local/r8-basic
# docker run --privileged --rm --name r8 --hostname r8  --network=bridge  -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /mnt/c/:/mnt/c:rw  local/r8-basic
# ssh -o StrictHostKeyChecking=no -p 10022 root@this_host
#
# bridged netwok so the container can be ssh-ed from host
# the container cannot be pinged from other hosts
# the container can ping outside world
# docker network create --driver bridge --subnet 10.0.0.0/16 mybridge1 
# to ssh to the container from other hosts, 22 must be mapped 
#
# docker create --storage-opt size=50G  --privileged --name r8  --network=nw1  --ip=10.0.0.2 -p10022:22   -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /data/user/wlin:/root/data:rw  local/r8-basic # storage-opt only works with 'create'
# docker start r8
# 
# docker run --privileged --rm --name r8 --hostname r8  --network=mybridge1  --ip=10.0.0.2 -p10022:22  -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /mnt/c:/mnt/c:rw  local/r8-basic
# enable docker in docker
# docker run --privileged --rm --name r8 --hostname r8  --network=mybridge1  --ip=10.0.0.2 -p10022:22  -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /var/run/docker.sock:/var/run/docker.sock -v /mnt/c:/mnt/c:rw  local/r8-basic
# docker run --privileged --rm --name r8  --network=none   -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ~/repo:/mnt/repo:ro  local/r8-basic
# docker network connect nw1 r8
# docker network disconnect nw1 r8
# ssh -o StrictHostKeyChecking=no -p 10022 root@this_host
#
#
# macVlan so the container can be ssh-ed from other hosts
# the container cannot be pinged from host. but can be pinged from other hosts
# the container cannot ping host. but the containercan ping from other hosts
# the container cannot ping outside world
# parent must be host's interface
# subnet and gateway must be the same as host's interface
# use 'ip r' to find default gateway and 'ip a' to find subnet
# docker network create -d macvlan --subnet=10.244.17.0/24 --gateway=10.244.17.251 -o parent=bond0.417 nw2 
# docker run --privileged --name r8  --network=nw2 -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ~/repo:/mnt/repo:ro  local/r8-basic
#
#
# docker run --privileged --name r8   -p 10080:80 -p 10022:22 -p 10443:443 -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro                         local/r8-basic
# docker run --privileged --name r8   -p 10080:80 -p 10022:22 -p 10443:443 -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ~/repo:/mnt/repo:ro  local/r8-basic
# ssh -o StrictHostKeyChecking=no -p 10022 root@localhost
# docker stop   r8
# docker rm   r8
# docker rmi local/r8-basic

#Once the container is running, login as root into the container and run the following commands to finish installation
# ssh -o StrictHostKeyChecking=no -p 2222 root@localhost    # because of MacOS's limitation you cannot ssh using containers port 22. You must use '-p 2222'
# cd /myrepo/mapr-config ; ansible-playbook install_Zulu_JDK_8.yaml -i ./hosts
# cd /myrepo/mapr-config ; ansible-playbook install_dev_edge.yaml   -i ./hosts
