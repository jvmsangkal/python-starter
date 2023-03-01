.PHONY: release dev run test format clean
.DEFAULT: help

help: ## Display this help message
	@echo "Please use \`make <target>\` where <target> is one of"
	@awk -F ':.*?## ' '/^[a-zA-Z]/ && NF==2 {printf "\033[36m  %-25s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

clean: ## Remove general artifact files
	find . -name '.coverage' -delete
	find . -name '*.pyc' -delete
	find . -name '*.pyo' -delete
	find . -name '.pytest_cache' -type d | xargs rm -rf
	find . -name '__pycache__' -type d | xargs rm -rf
	find . -name '.ipynb_checkpoints' -type d | xargs rm -rf

format: dev ## Scan and format all files with pre-commit
	venv/bin/pre-commit run --all-files

venv: ## Create virtual environment if venv directory not present
	python3 -m venv venv
	venv/bin/pip install -U pip pip-tools wheel --no-cache-dir

requirements.txt: venv requirements.in ## Generate requirements for release
	venv/bin/pip-compile -o requirements.txt requirements.in

requirements-dev.txt: venv requirements.in requirements-dev.in ## Generate requirements for dev
	venv/bin/pip-compile -o requirements-dev.txt requirements-dev.in

release: requirements.txt ## Install dependencies for release
	venv/bin/pip-sync requirements.txt

dev: requirements-dev.txt  ## Install dependencies for dev
	venv/bin/pip-sync requirements-dev.txt
	venv/bin/pre-commit install

run: dev db ## Run with dev dependencies
	venv/bin/dagit -h 0.0.0.0 -p 3000

test: dev ## Run all tests with coverage
	venv/bin/pytest tests --cov=src -v --cov-report=term-missing
