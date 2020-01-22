ERLC=/usr/bin/erlc
ERLCFLAGS=-o
BEAMDIR=ebin
SRCDIR=src

all: 
	@ mkdir -p ./$(SRCDIR)/$(BEAMDIR);
	@ $(ERLC) $(ERLCFLAGS) ./$(SRCDIR)/$(BEAMDIR) $(SRCDIR)/*.erl;
	@ erl -pa ./$(SRCDIR)/$(BEAMDIR) -noshell -eval "panel:main().";

clean: 
	@ rm -R $(BEAMDIR);