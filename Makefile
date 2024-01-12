.PHONY: release dev run test format clean upgrade-package
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
	python -m venv venv
	./venv/bin/python -m pip install pip-tools

requirements.txt: venv ## Generate requirements for release
	venv/bin/pip-compile -o requirements.txt pyproject.toml

dev-requirements.txt: venv ## Generate requirements for dev
	venv/bin/pip-compile --extra dev -o dev-requirements.txt pyproject.toml

release: requirements.txt ## Install dependencies for release
	venv/bin/pip-sync requirements.txt

dev: dev-requirements.txt  ## Install dependencies for dev
	venv/bin/pip-sync dev-requirements.txt
	venv/bin/pre-commit install

run: dev ## Run with dev dependencies
	./venv/bin/python -m src.py_starter.__init__

test: dev ## Run all tests with coverage
	venv/bin/pytest tests --cov=src -v --cov-report=term-missing

upgrade-package: dev-requirements.txt ## https://pip-tools.readthedocs.io/en/latest/#updating-requirements
	./venv/bin/pip-compile --upgrade-package $(ARGS)
