KIND_CMD     := go run sigs.k8s.io/kind@v0.23.0
HELM_CMD     := helm
KUBECTL_CMD  := kubectl
CLUSTER_NAME := dev-helm-chart-cluster

.DEFAULT_GOAL     := help

.PHONY: clean 
clean: kind/down ## Clean up all resources

.PHONY: help
help: ## Display this help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_\/-]+:.*?## / {printf "\033[34m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | \
		sort | \
		grep -v '#'

.PHONY: kind/up
kind/up: ## Deploy kind cluster
	@${KIND_CMD} create cluster --config ./kind.yaml --name ${CLUSTER_NAME}

.PHONY: kind/down
kind/down: ## Destroy kind cluster
	@${KIND_CMD} delete cluster --name ${CLUSTER_NAME}

.PHONY: otel-lgtm/deploy
otel-lgtm/deploy: ## Deploy OpenTelemetry Collector with LGTM
	@${HELM_CMD} upgrade --install lgtm ./otel-lgtm-dev

.PHONY: otel-lgtm/delete
otel-lgtm/delete: ## Delete OpenTelemetry Collector with LGTM
	@${HELM_CMD} delete lgtm

.PHONY: otel-lgtm/port-forward
otel-lgtm/port-forward: ## Port forward OpenTelemetry Collector with LGTM
	@${KUBECTL_CMD} port-forward svc/lgtm-grafana 8080:80

.PHONY: temporal/deploy
temporal/deploy: ## Deploy Temporal
	@${HELM_CMD} upgrade --install temporal ./temporal-dev

.PHONY: temporal/delete
temporal/delete: ## Delete Temporal
	@${HELM_CMD} delete temporal

.PHONY: temporal/port-forward/api
temporal/port-forward/api: ## Port forward Temporal API
	@${KUBECTL_CMD} port-forward svc/temporal 7233:7233

.PHONY: temporal/port-forward/ui
temporal/port-forward/ui: ## Port forward Temporal API
	@${KUBECTL_CMD} port-forward svc/temporal-ui 8080:8080