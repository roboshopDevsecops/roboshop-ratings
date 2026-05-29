docker-build:
	git pull
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 349558942960.dkr.ecr.us-east-1.amazonaws.com
	docker build -t 349558942960.dkr.ecr.us-east-1.amazonaws.com/roboshop-ratings:$(image_tag) .
	trivy image 349558942960.dkr.ecr.us-east-1.amazonaws.com/roboshop-ratings:$(image_tag) -s CRITICAL,HIGH --ignore-unfixed
	docker push 349558942960.dkr.ecr.us-east-1.amazonaws.com/roboshop-ratings:$(image_tag)

docker-build-db:
	git pull
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 349558942960.dkr.ecr.us-east-1.amazonaws.com
	docker build -t 349558942960.dkr.ecr.us-east-1.amazonaws.com/roboshop-ratings-db:latest ./db
	trivy image 349558942960.dkr.ecr.us-east-1.amazonaws.com/roboshop-ratings-db:latest -s CRITICAL,HIGH --ignore-unfixed
	docker push 349558942960.dkr.ecr.us-east-1.amazonaws.com/roboshop-ratings-db:latest

argocd-deploy:
	argocd login $(argocd_server) --skip-test-tls --username admin --password $(argocd_admin_password)
	argocd app create roboshop-ratings --sync-policy auto --upsert --repo https://github.com/roboshopDevsecops/roboshop-helm-v1.git --path . --dest-server https://kubernetes.default.svc --dest-namespace default --helm-set-string image_tag=$(image_tag) --values values/roboshop-ratings.yml
