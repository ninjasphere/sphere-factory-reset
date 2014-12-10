run: 
	docker run --volumes-from my-data --detach=true -p 80:80 --name=image-server image-server
	@echo add a port forward on the NAT interface of your docker VM from 1080 to 80

build:
	docker build -t image-server .

debug:
	docker run --volumes-from my-data -it -rm -p 80:80 --name=image-server image-server bash

clean:
	docker stop image-server
	docker rm image-server
