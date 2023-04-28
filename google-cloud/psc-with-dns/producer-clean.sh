REGION=europe-west1
ZONE=$REGION-b

gcloud compute service-attachments delete published-service --region=$REGION --quiet

gcloud compute forwarding-rules delete l7-ilb-forwarding-rule --region=$REGION --quiet

gcloud compute target-http-proxies delete l7-ilb-proxy --region=$REGION --quiet

gcloud compute url-maps delete l7-ilb-map --region=$REGION --quiet

gcloud compute backend-services remove-backend  l7-ilb-backend-service --instance-group-zone=$ZONE --instance-group=psc-instance-group  --region=$REGION --quiet

gcloud compute backend-services delete l7-ilb-backend-service  --region=$REGION --quiet

gcloud compute health-checks delete http-health-check --region=$REGION --quiet

gcloud compute instance-groups unmanaged remove-instances psc-instance-group --instances=app-server-1 --zone=$ZONE --quiet

gcloud compute instance-groups unmanaged delete psc-instance-group --zone=$ZONE --quiet

gcloud compute instances delete app-server-1 --zone $ZONE  --quiet

gcloud compute routers nats delete cloud-nat-us-central1 --router=cloud-router-for-nat --region $REGION --quiet

gcloud compute routers delete cloud-router-for-nat --region $REGION --quiet

gcloud compute firewall-rules delete fw-allow-proxy-only-subnet --quiet

gcloud compute firewall-rules delete fw-allow-health-check --quiet

gcloud compute firewall-rules delete allow-to-ingress-nat-subnet  --quiet

gcloud compute networks subnets delete psc-nat-subnet --region $REGION --quiet

gcloud compute networks subnets delete proxy-subnet-europe-west  --region $REGION --quiet

gcloud compute addresses delete lb-ip --region=$REGION --quiet

gcloud compute networks subnets delete load-balancer-subnet --quiet

gcloud compute networks subnets delete gce-subnet --quiet

gcloud compute networks delete producer-vpc --quiet
