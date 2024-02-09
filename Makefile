.PHONY: get-deb clean-deb

DIST_DIR := dist


clean-deb:
	rm -rf $(DIST_DIR)
	mkdir $(DIST_DIR)

get-deb: clean-deb
# The eval and shell commands here are evaluated when the recipe is parsed, so we put the cleanup
# into a prerequisite make step, in order to ensure they happen prior to the download.
	$(eval DLFILE = $(shell wget --content-disposition -P $(DIST_DIR)/ "${deb}" 2>&1 | grep "Saving to: " | sed 's/Saving to: ‘//' | sed 's/’//'))
	$(eval DLFILE := $(if $(DLFILE),$(DLFILE),$(notdir $(deb))))

	$(eval DEBFILE = $(shell echo "${DLFILE}" | sed "s/\?.*//"))
	[ "${DLFILE}" = "${DEBFILE}" ] || mv "${DLFILE}" "${DEBFILE}"

	# GH artifacts are zipped, so we need to extract them
	@if [ "$(shell echo $(DLFILE) | rev | cut -d'.' -f1 | rev)" = "zip" ]; then \
		unzip -d $(DIST_DIR)/ $(DIST_DIR)/$(DLFILE); \
		rm $(DIST_DIR)/$(DLFILE); \
	fi
