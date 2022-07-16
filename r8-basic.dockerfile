FROM local/r8-systemd  AS baseos
ENV container docker

#RUN yum groups mark convert

#RUN yum clean all; yum update -y ; yum -y install passwd; echo root | passwd --stdin root ; yum -y install httpd openssh-server openssh-clients initscripts;  echo 'set -o vi' >> /etc/profile; chkconfig sshd on ; chkconfig httpd on ;echo 'export TERM=linux' >> /etc/profile 

RUN yum clean all; yum update -y ; \
    yum install -y epel-release  
RUN yum install -y httpd mod_ssl openssh-server openssh-clients initscripts sudo  passwd rsyslog cronie netcat which procps net-tools iproute sysstat libmemcached ; \
    echo 'set -o vi; export EDITOR=vi' >> /etc/profile; \
    echo 'export TERM=linux' >> /etc/profile ; \
    chkconfig sshd on ; chkconfig httpd on ; \
    systemctl enable rsyslog; systemctl enable crond ; \
    mkdir /root/.ssh; chmod 600 /root/.ssh; ls -l /root/.ssh ; \
    mkdir /mnt/repo ; chmod 777 /mnt/repo

# install gcc, etc
RUN yum group install -y "Development Tools"


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

#FROM scratch
#COPY --from=base_ansible / /

EXPOSE 22
EXPOSE 80

VOLUME [ "/sys/fs/cgroup" ]
# ENTRYPOINT will always run. CMD will be appended to ENTRYPOINT. CMD can be replaced by command line parameter when 'docker run'
ENTRYPOINT /usr/sbin/init
#CMD ["/usr/sbin/init"]

# ------------------------------------------------------------------
#DOCKER_BUILDKIT=1 docker build -f r8-basic.dockerfile --rm -t local/r8-basic . 
# docker network create --driver bridge --subnet 10.0.0.0/16 nw1 
# docker run --privileged --name r8  --network=nw1  --ip=10.0.0.2  -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ~/repo:/mnt/repo:ro  local/r8-basic
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
