#!/usr/bin/env make

.PHONY: all badge check clean doc format help lint report test

.DEFAULT_GOAL	:= default

COVERAGE	:= 90	# minimum percentage for code coverage
CTAGS		:= $(shell which ctags)
PIP		:= $(shell which pip3)
PYTHON		:= $(shell which python3)

PROJECT		:= helloworld
SRCS		:= $(wildcard $(PROJECT)/*.py $(PROJECT)/tests/*.py)

all:	check test report run
default: format check test

help:
	@echo
	@echo "Default goal: ${.DEFAULT_GOAL}"
	@echo
	@echo "  all:    style and test"
	@echo "  preen:  format and lint"
	@echo "  format: format code, sort imports and requirements"
	@echo "  lint:   check code"
	@echo "  test:   run unit tests"
	@echo "  doc:    document module"
	@echo "  clean:  delete all generated files"
	@echo
	@echo "Initialise virtual environment (.venv) with:"
	@echo
	@echo "  pip3 install -U virtualenv; python3 -m virtualenv .venv; source .venv/bin/activate; pip3 install -Ur requirements.txt"
	@echo
	@echo "Start virtual environment (.venv) with:"
	@echo
	@echo "  source .venv/bin/activate"
	@echo
	@echo Deactivate with:
	@echo
	@echo "  deactivate"
	@echo

preen:	format tags lint

format:
	@ruff format
	@sort-requirements requirements.txt

lint:
	@ruff check --output-format grouped --fix
	@sort-requirements --check requirements.txt

lint_unsafe:
	@ruff check --unsafe-fixes --fix --show-fixes

tags:
ifdef CTAGS
	@ctags --recurse -o tags $(SRCS)
endif


test: preen
	@pytest --verbose --cov --cov-config=.coveragerc --cov-report=html

run:
	@python3 -m $(PROJECT) -h
	@python -m $(PROJECT) --version
	@python -m $(PROJECT) --log DEBUG

report:	doc badge

doc:	test
	# generates pydoc documentation
	@pdoc $(PROJECT) !$(PROJECT).tests -o public
	@pytest --html=public/reports/pytest_report.html --self-contained-html
	# generates sphinx documentation
	(cd $(PWD)/docs; make html)

badge:
	@pytest --junitxml=public/pytest_report.xml
	@bandit --configfile .bandit.yaml --recursive \
	  --format html --output public/bandit_report.html $(PROJECT)
	@genbadge tests \
	  --input-file public/pytest_report.xml \
	  --output-file public/tests.svg

clean:
	# clean build distribution
	$(PYTHON) setup.py clean
	# clean generated documents
	(cd docs; make clean)
	# clean generated artefacts
	-$(RM) -rf __pycache__ **/__pycache__
	-$(RM) -rf .coverage
	-$(RM) -rf .pytest_cache
	-$(RM) -rf cover
	-$(RM) -rf public
	-$(RM) -rf target
	-$(RM) -v *.pyc *.pyo *.py,cover
	-$(RM) -v **/*.pyc **/*.pyo **/*.py,cover
