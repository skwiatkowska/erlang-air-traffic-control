ERLC=/usr/bin/erlc
ERLCFLAGS=-o
BEAMDIR=ebin
SRCDIR=src

all: 
	@ mkdir -p ./$(SRCDIR)/$(BEAMDIR);
	@ $(ERLC) $(ERLCFLAGS) ./$(SRCDIR)/$(BEAMDIR) $(SRCDIR)/*.erl;
	@ erl -pa ./$(SRCDIR)/$(BEAMDIR) -eval -noshell "panel:main().";
