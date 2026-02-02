# 基本變數
IMAGE_NAME=monorepo
CONTAINER_NAME=monorepo
CONTAINER_PORT=3000

# 預設目標
.DEFAULT_GOAL := help

# 使用的 Shell
SHELL := /bin/bash

# 可用目標說明
.PHONY: help
help:
		@echo "可用目標："
		@echo "  build      - 建立 Docker image"
		@echo "  run        - 啟動 Docker container"
		@echo "  clean      - 刪除 Docker container 和 image"
		@echo "  list       - 列出 Docker 所有 container 和 image"
		@echo "  attach     - 進入正在運行的 container"
		@echo "  reattach   - 重新連接到 container（若 container 已退出則重新啟動）"

# 建立 Docker 映像檔
.PHONY: build
build:
		docker build \
				--no-cache \
				--build-arg buildtime_CONTAINER_PORT=${CONTAINER_PORT} \
				-t ${IMAGE_NAME} .

# 啟動容器
.PHONY: run
run:
		@docker run -it --name $(CONTAINER_NAME) \
				-p $(CONTAINER_PORT):$(CONTAINER_PORT) \
				-v $(PWD):/app \
				-w /app \
				-e CONTAINER_PORT=$(CONTAINER_PORT) \
				${IMAGE_NAME}

# 停止容器
.PHONY: stop
stop:
		docker stop $(CONTAINER_NAME)

# 啟動已停止的容器
.PHONY: start
start:
		docker start $(CONTAINER_NAME)

# 進入正在運行的容器
.PHONY: attach
attach:
		@CONTAINER_STATUS=$(shell docker ps -a --filter "name=$(CONTAINER_NAME)" --format "{{.State}}"); \
		if [ "$${CONTAINER_STATUS}" = "running" ]; then \
				printf "[INFO] Container $(CONTAINER_NAME) is running. Attaching...\n"; \
				docker exec -it $(CONTAINER_NAME) ${SHELL}; \
		elif [ -z "$${CONTAINER_STATUS}" ]; then \
				printf "[ERROR] Container $(CONTAINER_NAME) does not exist.\n"; \
		else \
				printf "[WARNING] Container $(CONTAINER_NAME) is not running (state: $${CONTAINER_STATUS}). Use 'make reattach' to restart and attach.\n"; \
		fi

# 重新連接到容器（若容器已退出則重新啟動）
.PHONY: reattach
reattach:
		@CONTAINER_STATUS=$(shell docker ps -a --filter "name=$(CONTAINER_NAME)" --format "{{.State}}"); \
		if [ "$${CONTAINER_STATUS}" = "exited" ]; then \
				printf "[WARNING] Container $(CONTAINER_NAME) is exited. Restarting...\n"; \
				docker start $(CONTAINER_NAME) >> /dev/null; \
		fi; \
		printf "[INFO] Container $(CONTAINER_NAME) is running.\n"; \
		docker exec -it $(CONTAINER_NAME) ${SHELL}

# 清理容器和映像檔
.PHONY: clean
clean:
		docker stop $(CONTAINER_NAME) || true
		docker rm $(CONTAINER_NAME) || true
		docker rmi ${IMAGE_NAME} || true

# 列出所有 Docker 映像檔與容器
.PHONY: list
list:
		@echo "Docker 映像檔列表："
		docker images
		@echo "Docker 容器列表："
		docker ps -a
