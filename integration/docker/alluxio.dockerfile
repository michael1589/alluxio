FROM swr.cn-central-221.ovaijisuan.com/taichu-studio/alluxio-maven:3.8.4-jdk-8 AS alluxio-compiler
RUN mkdir -p /opt/src/alluxio && \
    cd /opt/src/alluxio && \
    go env -w  GOPROXY=https://goproxy.cn,direct

WORKDIR /opt/src/alluxio
COPY . .
COPY maven/settings.xml /usr/share/maven/ref/
COPY maven/settings.xml /usr/share/maven/conf/
RUN cd /opt/src/alluxio && /opt/src/alluxio/dev/scripts/generate-tarballs release -mvn-args "-Dlicense.skip=true,-T8C"
#ARG ALLUXIO_VERSION=$(grep -m1 "<version>" pom.xml | awk -F ">" '{print $2}' | awk -F "<" '{print $1}')
ARG ALLUXIO_VERSION="2.9.1-SNAPSHOT"
RUN export ALLUXIO_TARBALL=$(ls | grep ".tar.gz")
# (Alert):It's not recommended to set this Argument to true, unless you know exactly what you are doing

RUN cd /opt && mv /opt/src/alluxio/*.tar.gz . && \
    (if ls | grep -q ".tar.gz"; then tar -xzf *.tar.gz; fi) && \
    ln -s alluxio-* alluxio

RUN if [ ${ENABLE_DYNAMIC_USER} = "true" ] ; then \
       chmod -R 777 /opt/* ; \
    fi
CMD ls -lhrt && ls $ALLUXIO_TARBALL

