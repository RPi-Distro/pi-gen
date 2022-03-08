.PHONY: get-deb clean-deb

clean-deb:
	rm -rf dist
	mkdir dist

get-deb: clean-deb
# The eval and shell commands here are evaluated when the recipe is parsed, so we put the cleanup
# into a prerequisite make step, in order to ensure they happen prior to the download.
	$(eval DLFILE = $(shell wget --content-disposition -P deb/ "${deb}" 2>&1 | grep "Saving to: " | sed 's/Saving to: ‘//' | sed 's/’//'))
	$(eval DEBFILE = $(shell echo "${DLFILE}" | sed "s/\?.*//"))
	[ "${DLFILE}" = "${DEBFILE}" ] || mv "${DLFILE}" "${DEBFILE}"
