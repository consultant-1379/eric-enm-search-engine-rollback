ARG OS_BASE_IMAGE_NAME=sles
ARG OS_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release
ARG OS_BASE_IMAGE_TAG

FROM ${OS_BASE_IMAGE_REPO}/${OS_BASE_IMAGE_NAME}:${OS_BASE_IMAGE_TAG}

ARG COMMIT
ARG TIMESTAMP
ARG VERSION
ARG RSTATE

ARG PACKAGE_REPO_URL
ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG SLES_BASE_OS_REPO=sles_base_os_repo
ARG ENM_ISO_REPO_NAME=enm_iso_repo

LABEL \
com.ericsson.product-number="CXU 123 4567" \
com.ericsson.product-revision=$RSTATE \
org.opencontainers.image.title="sles Image" \
org.opencontainers.image.created=$TIMESTAMP \
org.opencontainers.image.revision=$COMMIT \
org.opencontainers.image.vendor="Ericsson" \
org.opencontainers.image.version=$VERSION

ARG USER_ID=170956
RUN echo "$USER_ID:x:$USER_ID:0:An identity for eric-enm-search-engine-rollback:/nonexistent:/bin/false" >> /etc/passwd && \
    echo "$USER_ID:!::0:::::" >> /etc/shadow

ADD https://arm1s11-eiffel004.eiffel.gic.ericsson.se:8443/nexus/content/repositories/releases/com/ericsson/oss/presentation/server/logging/ERIClogadmin_CXP9034286/3.6.2/ERIClogadmin_CXP9034286-3.6.2.rpm  var/

RUN zypper addrepo -C -G -f ${PACKAGE_REPO_URL}?ssl_verify=no $SLES_BASE_OS_REPO && \
    rpm -ivh /var/ERIClogadmin_CXP9034286*.rpm --nodeps && \
	zypper install -y shadow && \
	zypper install -y curl && \
	zypper --non-interactive install python-pip && \
    zypper --non-interactive install python3-pip && \
    zypper clean -a


RUN useradd es_admin && \
    groupadd es_admin

COPY --chown=170956:0 image_content/requirements.txt /tmp/
COPY --chown=170956:0 image_content/requirements_python3.txt /tmp/
COPY --chown=170956:0 image_content/export_logs_every_1_minute_with_retention_12_hours.json /opt/ericsson/elasticsearch/policies/

RUN pip2 install -r /tmp/requirements.txt && \
    pip3 install -r /tmp/requirements_python3.txt && \
	touch /var/log/messages && \
    chmod 777 /var/log/messages
USER $USER_ID
ENTRYPOINT ["rsyslogd", "-n"]
