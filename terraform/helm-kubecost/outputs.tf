output "kubecost-dashboard" {
  value = <<EOT

  To access the kubecost dashboard, run the command below and then visit http://localhost:9090/ in your web browser.
  
  kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090:9090
  
  EOT           
}