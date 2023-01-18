#docker build -f r9-systemd.dockerfile --rm -t local/r9-systemd .
#docker run --privileged --name r8   -p 10080:80 -p 10022:22 -p 10443:443 -d -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ~/repo:/mnt/repo:ro  local/r9-systemd



# systemd doesn't work for rocky 9. Don't use this docker file



FROM rockylinux/rockylinux:9
ENV container docker
#RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
#systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#rm -f /lib/systemd/system/multi-user.target.wants/*;\
#rm -f /etc/systemd/system/*.wants/*;\
#rm -f /lib/systemd/system/local-fs.target.wants/*; \
#rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \ 
#rm -f /lib/systemd/system/basic.target.wants/*;\
#rm -f /lib/systemd/system/anaconda.target.wants/*;
    #
RUN yum -y update; yum clean all
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

