run: build
	docker run --detach=true -p 80:80 --name=image-server image-server
	@echo add a port forward on the NAT interface of your docker VM from 1080 to 80

build:
	docker build -t image-server .

clean:
	docker stop image-server
	docker rm image-server
