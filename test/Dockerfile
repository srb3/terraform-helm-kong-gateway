FROM chef/inspec:5.18.15

RUN mkdir -p /etc/chef/accepted_licenses
COPY inspec-accepted-license /etc/chef/accepted_licenses/inspec

RUN apt-get update

RUN apt install -y build-essential ruby-dev coreutils bash git
RUN ln -s /usr/bin/install /bin/install
RUN gem install train-kubernetes
RUN inspec plugin install train-kubernetes
COPY attributes.yaml /attributes.yaml
