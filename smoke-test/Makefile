CC ?= $(JIELI_TOOLCHAIN)/bin/clang
CFLAGS = --target=mips

.PHONY: check
check:
	@echo "JIELI_TOOLCHAIN=$(JIELI_TOOLCHAIN)"
	@echo "AC79_SDK=$(AC79_SDK)"
	@test -n "$(JIELI_TOOLCHAIN)" || { echo "JIELI_TOOLCHAIN not set"; exit 1; }
	@test -n "$(AC79_SDK)" || { echo "AC79_SDK not set"; exit 1; }
	@test -d "$(JIELI_TOOLCHAIN)" || { echo "JIELI_TOOLCHAIN dir missing"; exit 1; }
	@test -d "$(AC79_SDK)" || { echo "AC79_SDK dir missing"; exit 1; }
	@test -x "$(JIELI_TOOLCHAIN)/bin/clang" || { echo "clang not found in toolchain"; exit 1; }
	@echo "smoke test: all checks passed"
