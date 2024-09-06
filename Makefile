all:
	#INFO: Cleaning up	 
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	#INFO: Deleting eunit test
	rm -rf test_ebin;
	#INFO: Deleting tilde files and beams
	rm -rf apps/*/src/*.beam;
	rm -rf test/*.beam test/*/*.beam;
	rm -rf *.beam;
	#INFO: Deleting files and dirs created during builds
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock
	#INFO: Compile application
	rm -rf common_include;
	cp -r ~/erlang/simple_system/common_include .
	rm -rf release;
	rebar3 compile;
	rm -rf _build*;
	rm -rf rebar.lock
	git status
	echo Ok there you go!
	#INFO: no_ebin_commit ENDED SUCCESSFUL
clean:
	#INFO: clean STARTED
	#INFO: Cleaning up	 
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	#INFO: Deleting eunit test
	rm -rf test_ebin;
	#INFO: Deleting tilde files and beams
	rm -rf apps/*/src/*.beam;
	rm -rf test/*.beam test/*/*.beam;
	rm -rf *.beam;
	#INFO: Deleting files and dirs created during builds
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock
	#INFO: Compile application
	rm -rf common_include;
	rm -rf _build*;
	#INFO: clean ENDED SUCCESSFUL
eunit: 
	#INFO: eunit STARTED
	#INFO: Cleaning up	 
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	#INFO: Deleting eunit test
	rm -rf test_ebin;
	#INFO: Deleting tilde files and beams
	rm -rf apps/*/src/*.beam;
	rm -rf test/*.beam test/*/*.beam;
	rm -rf *.beam;
	#INFO: Deleting files and dirs created during builds
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock
	#INFO: Creating eunit test code using test_ebin dir;
	mkdir test_ebin;
	#rm test/dependent_apps.erl;
	#cp /home/joq62/erlang/dev_support/dependent_apps.erl test;
	erlc -I include -I /home/joq62/erlang/include -o test_ebin test/*.erl;
	erlc -I ../../infra/rd/include -I /home/joq62/erlang/include -o test_ebin ../../infra/rd/src/*.erl;
	cp ../../infra/rd/src/rd.app.src test_ebin/rd.app;
	erlc -I ../../infra/log/include -I /home/joq62/erlang/include -o test_ebin ../../infra/log/src/*.erl;
	cp ../../infra/log/src/log.app.src test_ebin/log.app;
	#INFO: Creating Common applications needed for testing
	#INFO: Compile application
	rm -rf common_include;
	cp -r ~/erlang/simple_system/common_include .
	rebar3 compile
	rebar3 release;
	#INFO: Starts the eunit testing .................
	erl -pa test_ebin\
	 -sname test_temp\
	 -run $(m) start\
	 -setcookie a
