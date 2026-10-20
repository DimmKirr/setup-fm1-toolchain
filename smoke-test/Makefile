.PHONY: check
check:
	@test -n "$(JIELI_TOOLCHAIN)" || { echo "JIELI_TOOLCHAIN not set"; exit 1; }
	@test -n "$(AC79_SDK)" || { echo "AC79_SDK not set"; exit 1; }
	@test -d "$(JIELI_TOOLCHAIN)" || { echo "JIELI_TOOLCHAIN dir missing"; exit 1; }
	@test -d "$(AC79_SDK)" || { echo "AC79_SDK dir missing"; exit 1; }
	@test -x "$(JIELI_TOOLCHAIN)/bin/clang" || { echo "clang not found in toolchain"; exit 1; }
	@"$(JIELI_TOOLCHAIN)/bin/clang" --version
	@test -f "$(AC79_SDK)/Makefile" || { echo "SDK Makefile missing"; exit 1; }
	@echo "smoke test: all checks passed"
