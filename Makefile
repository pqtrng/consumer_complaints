.PHONY: help clean clean-pyc clean-build list test test-all coverage docs release sdist

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_NAME = consumer_complaints
PYTHON_INTERPRETER = python3

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

help:
	@echo "clean - remove build artifacts"
	@echo "develop - set up dev environment"
	@echo "install-deps"
	@echo "install-pre-commit"
	@echo "setup-git"
	@echo "lint - check style with flake8"
	@echo "test - run tests quickly with the default Python"

create_environment:
ifeq (True,$(HAS_CONDA))
		@echo ">>> Detected conda, creating conda environment."
ifeq (3,$(findstring 3,$(PYTHON_INTERPRETER)))
	conda env remove --name $(PROJECT_NAME)
	conda create --name $(PROJECT_NAME) python=3.8 -y
else
	conda create --name $(PROJECT_NAME) python=2 -y
endif
		@echo ">>> New conda env created. Activate with:\nconda activate $(PROJECT_NAME)"
else
	$(PYTHON_INTERPRETER) -m pip install -q virtualenv virtualenvwrapper
	@echo ">>> Installing virtualenvwrapper if not already installed.\nMake sure the following lines are in shell startup file\n\
	export WORKON_HOME=$$HOME/.virtualenvs\nexport PROJECT_HOME=$$HOME/Devel\nsource /usr/local/bin/virtualenvwrapper.sh\n"
	@bash -c "source `which virtualenvwrapper.sh`;mkvirtualenv $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER)"
	@echo ">>> New virtualenv created. Activate with:\nworkon $(PROJECT_NAME)"
endif

clean:
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete

setup-git: install-pre-commit
	pre-commit install
	git config branch.autosetuprebase always

install-deps:
	pip install -r requirements/requirements.txt
	pip install -r requirements/test-requirements.txt

install-pre-commit:
	pip install pre-commit

develop: setup-git install-deps install-pre-commit

lint: install-pre-commit
	@echo "Linting Python files"
	pre-commit run -a
	@echo ""

test: develop lint
	@echo "Running Python tests"
	py.test .
	@echo ""
