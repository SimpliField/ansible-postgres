docker-image="geerlingguy/docker-debian8-ansible"
docker-container-id:=$(shell mktemp)

test: docker-run docker-test docker-stop

docker-pull:
	docker pull $(docker-image)

docker-run: docker-pull
	docker run --detach \
	--volume="${PWD}":/etc/ansible/roles/role_under_test:ro \
	$(docker-image) \
	/sbin/init > $(docker-container-id)

docker-stop:
	docker stop $(shell cat ${docker-container-id})

docker-test: docker-requirements docker-test-syntax docker-test-role

docker-requirements:
	docker exec "$(shell cat ${docker-container-id})" ansible-galaxy install SimpliField.packages
docker-test-syntax:
	docker exec --tty "$(shell cat ${docker-container-id})" env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/test.yml --syntax-check
docker-test-role:
	docker exec "$(shell cat ${docker-container-id})" ansible-playbook /etc/ansible/roles/role_under_test/tests/test.yml -e "$(ROLE_OPTIONS)"
