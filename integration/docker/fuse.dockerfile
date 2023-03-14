FROM centos:7 as build_java8
#RUN \
#    yum update -y && yum upgrade -y && \
#    yum install -y java-1.8.0-openjdk-devel java-1.8.0-openjdk && \
#    yum clean all
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk
# Disable JVM DNS cache in java8 (https://github.com/Alluxio/alluxio/pull/9452)
#RUN echo "networkaddress.cache.ttl=0" >> /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/java.security


FROM build_java8 AS final

WORKDIR /

# Install libfuse2 and libfuse3. Libfuse2 setup is modified from cheyang/fuse2:ubuntu1604-customize to be applied on centOS
#RUN yum install -y ca-certificates pkgconfig wget udev git && \
#    yum install -y gcc gcc-c++ make cmake gettext-devel libtool autoconf && \
#    git clone https://github.com/michael1589/libfuse.git && \
#    cd libfuse && \
#    git checkout fuse_2_9_5_customize_multi_threads && \
#    bash makeconf.sh && \
#    ./configure && \
#    make -j8 && \
#    make install && \
#    cd .. && \
#    rm -rf libfuse && \
#    yum remove -y gcc gcc-c++ make cmake gettext-devel libtool autoconf wget git && \
#    yum install -y fuse3 fuse3-devel fuse3-lib && \
#    yum clean all

# Configuration for the modified libfuse2
ENV MAX_IDLE_THREADS "64"

# /lib64 is for rocksdb native libraries, /usr/local/lib is for libfuse2 native libraries
ENV LD_LIBRARY_PATH "/lib64:/usr/local/lib:${LD_LIBRARY_PATH}"

ARG ALLUXIO_USERNAME=alluxio
ARG ALLUXIO_GROUP=alluxio
ARG ALLUXIO_UID=1000
ARG ALLUXIO_GID=1000

# For dev image to know the user
ENV ALLUXIO_DEV_UID=${ALLUXIO_UID}

ARG ENABLE_DYNAMIC_USER=true

# Add Tini for Alluxio helm charts (https://github.com/Alluxio/alluxio/pull/12233)
# - https://github.com/krallin/tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini
CMD sleep 10