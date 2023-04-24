gcloud compute backend-services update http-backend-service --security-policy=""  --global

gcloud compute security-policies delete rate-limit-and-deny-http --quiet

gcloud compute forwarding-rules delete default-http-backend-service-proxy-forwarding-rule --global --quiet

gcloud compute target-http-proxies delete default-http-backend-service-proxy --quiet

gcloud compute url-maps delete http-backend-service-url-map --quiet

gcloud compute backend-services delete http-backend-service --global --quiet

gcloud compute health-checks delete http-health-check --quiet

gcloud compute instance-groups unmanaged delete vm-ig1  --zone us-central1-b --quiet

gcloud compute instances delete vm-1-b2 --zone us-central1-b --quiet

gcloud compute instances delete vm-1-b1 --zone us-central1-b --quiet