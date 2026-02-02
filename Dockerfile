FROM node:24

ENV PNPM_HOME="/home/node/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV PNPM_STORE_PATH="/home/node/.pnpm-store"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    curl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

RUN mkdir -p /home/node/.local/share/pnpm $PNPM_STORE_PATH \
    && chown -R node:node /home/node

USER node

RUN curl -fsSL https://get.pnpm.io/install.sh | bash -s -- --version 10.20.0

RUN pnpm config set store-dir $PNPM_STORE_PATH \
    && pnpm completion bash > /home/node/completion-for-pnpm.bash \
    && echo 'source /home/node/completion-for-pnpm.bash' >> /home/node/.bashrc \
    && echo 'eval "$(starship init bash)"' >> /home/node/.bashrc

COPY --chown=node:node . .

ARG buildtime_CONTAINER_PORT=3000
EXPOSE ${buildtime_CONTAINER_PORT}

CMD ["bash"]