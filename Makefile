SHELL := $(shell which bash)
ROOT_DIR := $(shell pwd)
SCRIPTS_DIR := $(ROOT_DIR)/scripts
BUILD_DIR := $(ROOT_DIR)/.build
ENGINES_DIR := $(BUILD_DIR)/engines
SRC_DIR := $(BUILD_DIR)/src

ENGINES ?= lua lua55 luajit luau quickjs v8
CATEGORY ?=
RUNS ?= 5
WARMUP ?= 2
RESULTS_PATH ?=

export ROOT_DIR SCRIPTS_DIR BUILD_DIR ENGINES_DIR SRC_DIR ENGINES CATEGORY RUNS WARMUP

.PHONY: all setup bench report clean rebuild help \
        download download-lua download-lua55 download-luajit download-luau download-quickjs download-v8 \
        build-lua build-lua55 build-luajit build-luau build-quickjs build-v8

all: setup bench report

setup:
	@bash $(SCRIPTS_DIR)/setup.sh

bench:
	@bash $(ROOT_DIR)/runner/run.sh

report:
ifdef RESULTS_PATH
	@python3 $(ROOT_DIR)/report/generate.py $(RESULTS_PATH)
else
	@python3 $(ROOT_DIR)/report/generate.py
endif

# --- Download targets (individual retry) ---

download:
	@bash $(SCRIPTS_DIR)/download_sources.sh

download-lua:
	@ENGINES=lua bash $(SCRIPTS_DIR)/download_sources.sh

download-lua55:
	@ENGINES=lua55 bash $(SCRIPTS_DIR)/download_sources.sh

download-luajit:
	@ENGINES=luajit bash $(SCRIPTS_DIR)/download_sources.sh

download-luau:
	@ENGINES=luau bash $(SCRIPTS_DIR)/download_sources.sh

download-quickjs:
	@ENGINES=quickjs bash $(SCRIPTS_DIR)/download_sources.sh

download-v8:
	@ENGINES=v8 bash $(SCRIPTS_DIR)/download_sources.sh

# --- Build targets (individual retry) ---

build-lua:
	@bash $(SCRIPTS_DIR)/build_lua.sh

build-lua55:
	@bash $(SCRIPTS_DIR)/build_lua55.sh

build-luajit:
	@bash $(SCRIPTS_DIR)/build_luajit.sh

build-luau:
	@bash $(SCRIPTS_DIR)/build_luau.sh

build-quickjs:
	@bash $(SCRIPTS_DIR)/build_quickjs.sh

build-v8:
	@bash $(SCRIPTS_DIR)/build_v8.sh

# --- Clean ---

clean:
	@echo "Removing .build/ and results/ ..."
	@rm -rf $(BUILD_DIR) results/

rebuild: clean setup

help:
	@echo "lua-js-benchmark - Lua / JavaScript engine performance comparison"
	@echo ""
	@echo "Usage:"
	@echo "  make setup                       Initialize: check deps, download sources, build engines"
	@echo "  make bench                       Run all benchmarks"
	@echo "  make report                      Generate comparison report"
	@echo "  make all                         setup + bench + report"
	@echo ""
	@echo "  make setup ENGINES=\"lua luajit\"   Only setup specified engines"
	@echo "  make bench CATEGORY=compute      Only run specific category"
	@echo "  make bench ENGINES=\"lua luajit\"   Only benchmark specified engines"
	@echo "  make bench RUNS=10 WARMUP=3      Adjust iterations"
	@echo ""
	@echo "  make download-lua                Download Lua 5.4 source only"
	@echo "  make download-lua55              Download Lua 5.5 source only"
	@echo "  make download-luau               Download Luau source only"
	@echo "  make download-v8                 Download V8 source only"
	@echo "  make build-lua                   Build Lua 5.4 only"
	@echo "  make build-lua55                 Build Lua 5.5 only"
	@echo "  make build-luau                  Build Luau only"
	@echo "  make build-v8                    Build V8 only"
	@echo ""
	@echo "  make clean                       Remove .build/ and results/"
	@echo "  make rebuild                     Clean + setup"
	@echo ""
	@echo "Supported ENGINES: lua lua55 luajit luau quickjs v8"
