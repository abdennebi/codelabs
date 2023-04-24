REGION=europe-west1
ZONE=$REGION-b

gcloud compute instances delete db1 --zone=$ZONE --quiet

gcloud compute firewall-rules delete ssh-iap-consumer --quiet

gcloud compute forwarding-rules delete endpoint --region=$REGION --network=consumer-vpc --quiet

gcloud compute addresses delete psc-consumer-ip-1 --region=$REGION --quiet

gcloud compute networks subnets delete consumer-ep-subnet --region=$REGION --quiet

gcloud compute networks subnets delete db1-subnet --region=$REGION --quiet

gcloud compute networks delete consumer-vpc --quiet