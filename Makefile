all:	 
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	rm -rf test_ebin;
	rm -rf *.beam */*.beam;
	rm -rf test.rebar;
	rm -rf logs;
	rm -rf Mnesia.*;
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock;
	#INFO: Compile application
	rm -rf common_include;
	cp -r ~/erlang/common_include .
	rebar3 compile;
	rebar3 release;
	rm -rf _build;
	git status
	echo Ok there you go!
	#INFO: no_ebin_commit ENDED SUCCESSFUL
build_test:
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	rm -rf test_ebin;
	rm -rf *.beam */*.beam;
	rm -rf test.rebar;
	rm -rf logs;
	rm -rf Mnesia.*;
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock;
	rm -rf *_container;
	#INFO: Compile application
	rm -rf common_include;
	cp -r ~/erlang/common_include .
	rebar3 compile;
	rebar3 release
clean:
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	rm -rf test_ebin;
	rm -rf *.beam */*.beam;
	rm -rf test.rebar;
	rm -rf logs;
	rm -rf Mnesia.*;
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock;
	rm -rf *_container;
	rm -rf tar_dir;
	#INFO: Compile application
	rm -rf common_include;
	cp -r ~/erlang/common_include .
	rebar3 compile;
	rm -rf _build;
	rm -rf rebar.lock
#INFO: clean ENDED SUCCESSFUL
eunit: 
	rm -rf erl_cra* rebar3_crashreport;
	rm -rf *~ */*~ */*/*~ */*/*/*~;
	rm -rf test_ebin;
	rm -rf *.beam */*.beam;
	rm -rf test.rebar;
	rm -rf logs;
	rm -rf Mnesia.*;
	rm -rf _build;
	rm -rf ebin;
	rm -rf rebar.lock;
	rm -rf *_container;
#INFO: Creating eunit test code using test_ebin dir;
	mkdir test_ebin;
	rm -rf common_include;
	cp -r ~/erlang/common_include .
	erlc -I ~/erlang/common_include -o test_ebin test/*.erl;
	erlc -o test_ebin /home/joq62/erlang/new_setup/services/common/src/*.erl;
	rebar3 release;
	#INFO: Starts the eunit testing .................
	erl -pa test_ebin\
	 -pa _build/default/lib/log/ebin\
	 -pa _build/default/lib/cmn_server/ebin\
	 -pa _build/default/lib/service_discovery/ebin\
	 -sname test_appl\
	 -run $(m) start\
	 -setcookie a
