#FROM armdocker.rnd.ericsson.se/proj-eo-cm/eric-eo-cm-sles-base-jre:latest
# start with a linux OS image Ubuntu or Debian
FROM ubuntu:latest

ENV HOSTDB 127.0.0.1
ENV DBNAME custwfdb1
ENV ACT_PWD act_pwd
ENV ECM_PWD ecm_pwd

#ARG EXTERNAL_ARM_REPO=https://sekatearm2.ete.ka.sw.ericsson.se/artifactory/proj-ecm-yum-external-local-seka/rhel/7/x_64/packages/
#find location on web for liquibase

ARG LIQUIBASE_NAME=liquibase-3.8.2-1.el6.x86_64.rpm
ARG LIQUIBASE_HOME=/var/lib/liquibase
LABEL \
    com.ericsson.product-number="CXU 111 1111" \
    com.ericsson.product-revision=R1A \
    org.opencontainers.image.title="Cust-wf Service Image init2" \
    org.opencontainers.image.vendor="Ericsson"

RUN zypper --no-gpg-checks install -y ${EXTERNAL_ARM_REPO}${LIQUIBASE_NAME} && \
    zypper --no-gpg-checks install -y postgresql11 unzip

COPY liquibase ${LIQUIBASE_HOME}
COPY docker-entrypoint.sh /opt/

RUN mkdir -p /opt/ericsson/do/utils && \
    rm -rf /tmp/* && \
    chown -R ${EOCM_UID}:${EOCM_GID} /var/lib/liquibase/ /opt/docker-entrypoint.sh && \
    chmod +x /opt/docker-entrypoint.sh && \
    zypper remove -y unzip && \
    zypper clean --all

USER ${EOCM_UID}

ENTRYPOINT /opt/docker-entrypoint.sh ${HOSTDB} ${DBNAME} ${ACT_PWD} ${ECM_PWD}