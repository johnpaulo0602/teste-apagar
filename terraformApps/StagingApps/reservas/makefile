applyTerraform:
	terragrunt apply -lock=false && kubectl get pods -n monitoring

applyIngressRoute: applyTerraform
	kubectl apply -f ./ingressRoute.yaml -n monitoring && kubectl get IngressRoute -n monitoring

destroyTerraform:
	terragrunt destroy -lock=false && kubectl get pods -n monitoring
