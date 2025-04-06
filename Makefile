argocd=./app/argocd.yaml

help:
	@echo "1.	Run install to setup infra"
	@echo "2.	After install, run start to port forward Argo services"
	@echo "		To stop, run stop"
	@echo "3.	To tair down infro, run clean"

start:
	source utils/argo_cd_ui.sh

stop:
	pkill -f "port-forward" || echo "nothing to stop"

install: $(argocd)
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
