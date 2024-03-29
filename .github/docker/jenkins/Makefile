VAULT_TOKEN ?= $(shell cat $${HOME}/.vault-token)
LOG_LEVEL ?= WARNING
WIREMOCK_JOBS := abort cobertura connectionRefused error multiTestFailures success unstable
WIREMOCK_BLUE_OCEAN_URLS := steps/?limit=10000 tests/?status=FAILED&limit=1000 log changeSet artifacts tests/?limit=10000000 blueTestSummary
WIREMOCK_VERSION ?= 2.26.3
.DEFAULT_GOAL := help

.PHONY: build
build:  ## Build the jenkins image
	@env \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			build --no-cache jenkins

.PHONY: clean
clean:  ## Reset the environment; stop Jenkins
clean:
	@env \
		VAULT_TOKEN=${VAULT_TOKEN} \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			down --volumes

.PHONY: logs
logs:  ## Follow the log output for all Jenkins-related processes
	@env \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			logs --follow $${SERVICE}

# Start the local Jenkins controller (used as dependency target)
.PHONY: controller
controller:
	@env \
		VAULT_TOKEN=${VAULT_TOKEN} \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			up --detach jenkins

.PHONY: pull
pull:  ## Pull required images for all Jenkins-related processes
	@env \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			pull $${SERVICE}

.PHONY: restart
restart:  ## Restart the local Jenkins controller and related processes
	@env \
		VAULT_TOKEN=${VAULT_TOKEN} \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			restart $${SERVICE}

.PHONY: shell
shell:  ## Open a Bash shell on the local Jenkins controller
	@env \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			exec $${SERVICE:-jenkins} sh

.PHONY: shell-worker
shell-worker:  ## Open a Bash shell on the local Jenkins worker
	VAGRANT_CWD=workers/linux/ vagrant ssh

.PHONY: start
start:  ## Start the local Jenkins controller
start: controller
	@>&2 printf '\n'
	@>&2 printf 'Jenkins controller now running at http://localhost:18080\n'

.PHONY: start-linux-worker
start-linux-worker:  ## Start the local linux worker
	VAGRANT_CWD=workers/linux/ vagrant up --provision

.PHONY: stop-linux-worker
stop-linux-worker:  ## Stop the local linux worker
	VAGRANT_CWD=workers/linux/ vagrant halt

.PHONY: start-local-worker
start-local-worker:  ## Start the local worker
	[ ! -e agent.jar ] && wget --quiet -O agent.jar http://localhost:18080/jnlpJars/agent.jar || true
	{ nohup java -jar agent.jar -jnlpUrl http://localhost:18080/computer/local/slave-agent.jnlp > local.log 2>&1 & echo $$! > local.pid; }

.PHONY: stop-local-worker
stop-local-worker:  ## Stop the local worker
	[ -e local.pid ] && ( kill -9 `cat local.pid` ; rm local.pid ) || true

.PHONY: status
status:  ## Display the current status of Jenkins-related processes
	@env \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			ps $${SERVICE}

.PHONY: stop
stop:  ## Stop the local Jenkins controller and related processes
	@env \
		VAULT_TOKEN=${VAULT_TOKEN} \
		docker-compose \
			--log-level ${LOG_LEVEL} \
			--file docker-compose.yml \
			stop $${SERVICE}

.PHONY: wiremock-bo
wiremock-bo:  ## Hit the Blue Ocean URLs for wiremock tests
	@for JOB in $(WIREMOCK_JOBS); do\
		for URL in $(WIREMOCK_BLUE_OCEAN_URLS); do\
			echo "Browsing http://localhost:8080/blue/rest/organizations/jenkins/pipelines/it/getBuildInfoJsonFiles/$$JOB/runs/1/$$URL" ;\
			curl -I -s http://localhost:8080/blue/rest/organizations/jenkins/pipelines/it/getBuildInfoJsonFiles/$$JOB/runs/1/$$URL > /dev/null ;\
		done ;\
		echo "Browsing http://localhost:18080/job/it/job/getBuildInfoJsonFiles/job/$$JOB/1/cobertura/api/json?tree=results\[elements\[name,ratio,denominator,numerator\]\]&depth=3" ;\
		curl -I -s http://localhost:18080/job/it/job/getBuildInfoJsonFiles/job/$$JOB/1/cobertura/api/json?tree=results\[elements\[name,ratio,denominator,numerator\]\]&depth=3 > /dev/null ;\
	done

	cp -R __files ../src/test/resources/
	cp -R mappings ../src/test/resources/

.PHONY: wiremock-build-jobs
wiremock-build-jobs: ## Prepare the environment to run the wiremock tests, running the first builds for each job
	for JOB in $(WIREMOCK_JOBS); do\
		curl http://localhost:18080/job/it/job/getBuildInfoJsonFiles/job/$$JOB/build?delay=0sec ;\
	done

.PHONY: wiremock-clean
wiremock-clean:  ## Remove wiremock-standalone.jar
	rm -fr wiremock-standalone.jar
	rm -fr __files
	rm -fr mappings

wiremock-standalone.jar:  ## Download wiremock
	curl https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-standalone/$(WIREMOCK_VERSION)/wiremock-standalone-$(WIREMOCK_VERSION).jar -o wiremock-standalone.jar

.PHONY: wiremock-start
wiremock-start: wiremock-standalone.jar  ## Start wiremock to proxy all requests to the Jenkins instance
	java -jar wiremock-standalone.jar --proxy-all="http://localhost:18080" --record-mappings --verbose

.PHONY: help
help:  ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
