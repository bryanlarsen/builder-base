FROM debian:9
RUN apt-get update && apt-get install -y \
  wget \
  bzip2 \
  git \
  curl \
  python-pip

RUN pip install --upgrade pip anchorecli

# java required for updatebot
RUN apt-get update && apt-get install -y openjdk-8-jre

# chrome
RUN apt-get install -y libappindicator1 fonts-liberation libasound2 libnspr4 libnss3 libxss1 lsb-release xdg-utils libappindicator3-1 && \
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  dpkg -i google-chrome*.deb && \
  rm google-chrome*.deb


# USER jenkins
WORKDIR /home/jenkins

# Docker
ENV DOCKER_VERSION 17.12.0
RUN curl -f https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION-ce.tgz | tar xvz && \
  mv docker/docker /usr/bin/ && \
  rm -rf docker

# helm
ENV HELM_VERSION 2.11.0
RUN curl -f https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz  | tar xzv && \
  mv linux-amd64/helm /usr/bin/ && \
  mv linux-amd64/tiller /usr/bin/ && \
  rm -rf linux-amd64

# helm3
# RUN curl -L https://storage.googleapis.com/kubernetes-helm/helm-dev-v3-linux-amd64.tar.gz | tar xzv && \
#  mv linux-amd64/helm /usr/bin/helm3 && \
#  rm -rf linux-amd64

# lets use a patched release until this PR is merged or helm3 works again ;)
# https://github.com/kubernetes/helm/pull/4257#issuecomment-399491118

RUN curl -f -L https://github.com/jstrachan/helm/releases/download/untagged-93375777c6644a452a64/helm-linux-amd64.tar.gz -o helm3.tgz && \
  tar xf helm3.tgz && \
  mv helm /usr/bin/helm3

# gcloud
ENV GCLOUD_VERSION 187.0.0
RUN curl -f -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz | tar xzv && \
  mv google-cloud-sdk /usr/bin/
ENV PATH=$PATH:/usr/bin/google-cloud-sdk/bin

# install the docker credential plugin
RUN gcloud components install docker-credential-gcr

# jx-release-version
ENV JX_RELEASE_VERSION 1.0.15
RUN curl -f -o ./jx-release-version -L https://github.com/jenkins-x/jx-release-version/releases/download/v${JX_RELEASE_VERSION}/jx-release-version-linux && \
  mv jx-release-version /usr/bin/ && \
  chmod +x /usr/bin/jx-release-version

# exposecontroller
ENV EXPOSECONTROLLER_VERSION 2.3.34
RUN curl -f -L https://github.com/fabric8io/exposecontroller/releases/download/v$EXPOSECONTROLLER_VERSION/exposecontroller-linux-amd64 > exposecontroller && \
  chmod +x exposecontroller && \
  mv exposecontroller /usr/bin/

# skaffold
ENV SKAFFOLD_VERSION 0.19.0
RUN curl -f -Lo skaffold https://github.com/GoogleCloudPlatform/skaffold/releases/download/v${SKAFFOLD_VERSION}/skaffold-linux-amd64 && \
  chmod +x skaffold && \
  mv skaffold /usr/bin

# updatebot
ENV UPDATEBOT_VERSION 1.1.27
RUN curl -f  -o ./updatebot -L https://oss.sonatype.org/content/groups/public/io/jenkins/updatebot/updatebot/${UPDATEBOT_VERSION}/updatebot-${UPDATEBOT_VERSION}.jar && \
  chmod +x updatebot && \
  cp updatebot /usr/bin/ && \
  rm -rf updatebot

# draft
RUN curl -f https://azuredraft.blob.core.windows.net/draft/draft-canary-linux-amd64.tar.gz  | tar xzv && \
  mv linux-amd64/draft /usr/bin/ && \
  rm -rf linux-amd64

# kubectl
RUN curl -f -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
  chmod +x kubectl && \
  mv kubectl /usr/bin/

# jx
ENV JX_VERSION 1.3.399
RUN curl -f -L https://github.com/jenkins-x/jx/releases/download/v${JX_VERSION}/jx-linux-amd64.tar.gz | tar xzv && \
  mv jx /usr/bin/

# aws ecr docker credential helper.
# Currently using https://github.com/estahn/amazon-ecr-credential-helper as there are no releases yet in the main repo
# Main repo issues tracking at https://github.com/awslabs/amazon-ecr-credential-helper/issues/80
RUN mkdir ecr && \
  curl -f -L https://github.com/estahn/amazon-ecr-credential-helper/releases/download/v0.1.1/amazon-ecr-credential-helper_0.1.1_linux_amd64.tar.gz | tar -xzv -C ./ecr/ && \
  mv ecr/docker-credential-ecr-login /usr/bin/ && \
  rm -rf ecr

# ACR docker credential helper
#??https://github.com/Azure/acr-docker-credential-helper
RUN mkdir acr && \
  curl -f -L https://aadacr.blob.core.windows.net/acr-docker-credential-helper/docker-credential-acr-linux-amd64.tar.gz | tar -xzv -C ./acr/ && \
  mv acr/docker-credential-acr-linux /usr/bin/ && \
  rm -rf acr

# reflex
ENV REFLEX_VERSION 0.3.1
RUN curl -f -L https://github.com/ccojocar/reflex/releases/download/v${REFLEX_VERSION}/reflex_${REFLEX_VERSION}_linux_amd64.tar.gz | tar xzv && \
  mv reflex /usr/bin/

ENV KUSTOMIZE_VERSION 1.0.10
RUN curl -L -o /usr/bin/kustomize https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64 && chmod a+x /usr/bin/kustomize

ENV PATH ${PATH}:/opt/google/chrome

CMD ["helm","version"]
