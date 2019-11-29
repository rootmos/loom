VENV = $(shell pwd)/venv
HOST_PYTHON ?= python3

export HOST ?= localhost
export PORT ?= 8000
export LOOM_TARGET ?= http://$(HOST):$(PORT)

export PYTHON = $(VENV)/bin/python3
export PIP = $(VENV)/bin/pip
export PYTEST = $(VENV)/bin/pytest

PYTEST_OPTS ?= --workers=auto

ifneq ($(VERBOSE),)
PYTEST_OPTS += --verbose
else
PYTEST_OPTS += --quiet
endif

test: deps
ifdef TEST
	$(V)$(PYTEST) $(PYTEST_OPTS) "$(TEST)"
else
ifdef TESTS
	$(V)$(PYTEST) $(PYTEST_OPTS) -k "$(TESTS)"
else
	$(V)$(PYTEST) $(PYTEST_OPTS)
endif
endif

wait:
	@$(PYTHON) -c "import client; client.Client().wait_for_service()"

stop:
	@$(PYTHON) -c "import client; client.Client().stop()"

deps: .requirements.flag

$(VENV):
	$(HOST_PYTHON) -m venv $@

.requirements%flag: requirements%txt | $(VENV)
	$(PIP) install -r $<
	$(V)touch $@

clean:
	rm -rf .*.flag $(VENV)

.PHONY: test deps clean
