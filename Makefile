
clean:
	find . -name '*~' -exec rm {} \;

dist: clean
	cd ..;tar czf w`date +%Y%m%d`.tgz public_html
