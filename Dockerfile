FROM cimg/go:1.20-node

USER circleci
WORKDIR /home/circleci

RUN sudo npm install -g @commitlint/cli @commitlint/config-conventional

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.41.1

RUN curl -fsSL https://get.pulumi.com | sh \
  && echo "export PATH=${HOME}/.pulumi/bin:$PATH" >> ${HOME}/.profile

ENV PATH /home/circleci/.pulumi/bin:$PATH

RUN set -e \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
  \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  \
  && sudo apt update > /dev/null \
  \
  && sudo apt install -y gh > /dev/null

