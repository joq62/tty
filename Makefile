all:
#	service
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf *.applications ~/*.applications *configurations test_src/test_configurations;
	rm -rf  *~ */*~  erl_cra*;
#	app
	cp src/*.app ebin;
	erlc -I ../log_server/include -I include -o ebin src/*.erl;
	echo Done
start:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
#	common
	erlc -I ../log_server/include -o ebin ../../common/src/*.erl;
#	sd
	erlc -I ../log_server/include -o ebin ../sd/src/*.erl;
#	app
	cp src/*.app ebin;
	erlc -I ../log_server/include -I include -o ebin src/*.erl;
	erl -pa ebin\
	    -setcookie cookie_test\
	    -hidden\
	    -sname tty\
	    -run tty boot
unit_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf *.applications ~/*.applications *configurations;
	rm -rf  *~ */*~  erl_cra*;
	mkdir test_ebin;
	cp -R ../test_configurations .;
#	common
#	cp ../common/src/*.app ebin;
	erlc -D unit_test -I ../../include -o ebin ../../common/src/*.erl;
#	sd
	cp ../sd/src/*.app ebin;
	erlc -D unit_test -I ../../include -o ebin ../sd/src/*.erl;
#	bully
	cp ../bully/src/*.app ebin;
	erlc -D unit_test -I ../../include -I ../controller/include -o ebin ../bully/src/*.erl;
#	logger_infra
	cp ../logger_infra/src/*.app ebin;
	erlc -D unit_test -I ../../include -I ../controller/include -o ebin ../logger_infra/src/*.erl;
#	dbase_infra
	cp ../dbase_infra/src/*.app ebin;
	erlc -D unit_test -I ../../include -I ../controller/include -I ../dbase_infra/include -o ebin ../dbase_infra/src/*.erl;
#	host
	cp ../host/src/*.app ebin;
	erlc -D unit_test -I ../../include -I ../controller/include  -o ebin ../host/src/*.erl;
#	app
	cp src/*.app ebin;
	erlc -I ../../include -I ../controller/include -I ../dbase_infra/include -o ebin src/*.erl;
#	test application
	cp test_src/*.app test_ebin;
	erlc -D unit_test -I ../../include -I ../controller/include -o test_ebin test_src/*.erl;
	erl -pa ebin -pa test_ebin\
	    -setcookie cookie_test\
	    -hidden\
	    -sname tty\
	    -unit_test monitor_node test\
	    -unit_test cluster_id test\
	    -unit_test cookie cookie_test\
	    -run unit_test start_test test_src/test.config
