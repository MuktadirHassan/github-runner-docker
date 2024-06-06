# base
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

# set the github runner version
ARG RUNNER_VERSION="2.316.1"

# update the base packages
RUN apt-get update -y && apt-get upgrade -y 

# add a non-sudo user
RUN useradd -m docker

# install necessary packages
RUN apt-get install -y --no-install-suggests --no-install-recommends \
curl \
ca-certificates \
jq \
unzip \
gnupg \
lsb-release

# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# change ownership to non-sudo user
RUN chown -R docker /home/docker/actions-runner
# install some additional dependencies
RUN /home/docker/actions-runner/bin/installdependencies.sh

# install Docker CLI only
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-26.1.4.tgz | tar -xzv --strip-components=1 -C /usr/local/bin docker/docker

# install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm awscliv2.zip \
    && rm -rf aws

# copy over the start.sh script
COPY start.sh /home/docker/start.sh

# make the script executable
RUN chmod +x /home/docker/start.sh

# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

# set the entrypoint to the start.sh script
ENTRYPOINT ["/home/docker/start.sh"]