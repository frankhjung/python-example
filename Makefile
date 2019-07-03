#!/usr/bin/env make

.DEFAULT_GOAL := help

.PHONY: check clean dist doc help run test

SHELL	:= /bin/sh
COMMA	:= ,
EMPTY	:=
SPACE	:= $(EMPTY) $(EMPTY)
PYTHON	:= /usr/bin/python3

SRCS	:= main.py helloworld/helloworld.py tests/testhelloworld.py

all:	check test run doc dist

help:
	@echo
	@echo "Default goal: ${.DEFAULT_GOAL}"
	@echo "  all:   check cover run test doc dist"
	@echo "  check: check style and lint code"
	@echo "  run:   run against test data"
	@echo "  test:  run unit tests"
	@echo "  dist:  create a distrbution archive"
	@echo "  doc:   create documentation including test converage and results"
	@echo "  clean: delete all generated files"
	@echo
	@echo "Activate virtual environment (venv) with:"
	@echo
	@echo "pip3 install virtualenv; python3 -m virtualenv venv; source venv/bin/activate; pip3 install -r requirements.txt"
	@echo
	@echo "Deactivate with:"
	@echo
	@echo "deactivate"
	@echo
	@echo

check:
	# format code to googles style
	yapf --style google --parallel -i $(SRCS) setup.py
	# check with pylint
	pylint $(SRCS)
	# check distutils
	$(PYTHON) setup.py check

test:
	# $(PYTHON) -m unittest --verbose
	coverage run -m unittest --verbose tests/test*.py
	coverage report helloworld/helloworld.py

doc:
	# unit test code coverage
	coverage html -d cover helloworld/helloworld.py
	# create sphinx documentation
	(cd docs; make html)

dist:
	# copy readme for use in distribution
	# pandoc -t plain README.md > README
	# create source package and build distribution
	$(PYTHON) setup.py clean
	$(PYTHON) setup.py sdist --dist-dir=target/dist
	$(PYTHON) setup.py build --build-base=target/build

run:
	$(PYTHON) -m main -v
	$(PYTHON) -m main -h
	$(PYTHON) -m main --version

version:
	$(PYTHON) -m main --version

clean:
	# clean build distribution
	$(PYTHON) setup.py clean
	# clean generated documents
	(cd docs; make clean)
	$(RM) -rf cover
	$(RM) -rf .coverage
	$(RM) -rf __pycache__ helloworld/__pycache__ tests/__pycache__
	$(RM) -rf target
	$(RM) -v MANIFEST
	$(RM) -v **/*.pyc **/*.pyo **/*.py,cover
	$(RM) -v *.pyc *.pyo *.py,cover
