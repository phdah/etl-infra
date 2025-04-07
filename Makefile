argocd=./app/argocd.yaml
argo-workflow=./app/argo-workflow.yaml

help:
	@echo "1.	Run install to setup infra"
	@echo "2.	After install, run start to port forward Argo services"
	@echo "		To stop, run stop"
	@echo "3.	To tair down infro, run clean"
	@echo ""
	@echo "Note: You might have to start minikube first"

start:
	./utils/argo_cd_ui.sh

stop:
	pkill -f "port-forward" || echo "nothing to stop"

minikube-start:
	minikube start
	kubectl config use-context minikube

deps: $(argocd) $(argo-workflow)

install: deps
	# Terraform run
	terraform init
	terraform apply -auto-approve

clean:
	terraform destroy
	rm -rf terraform.* .terraform* || echo "no terraform files to remove"
	kind delete cluster --name argo-cd
	rm argo-cd-config || echo "no config files to remove"


$(argocd):
	curl -o $(argocd) https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

$(argo-workflow):
	echo "Get: https://github.com/argoproj/argo-workflows/releases/latest/download/install.yaml"

