bin_SCRIPTS = $(submit_scripts)
pkgdata_DATA = $(scripts)

my_pkglibdir = $(pkglibdir)
my_pkglib_DATA = $(libs)

sedit = $(SED) -e 's|@pkglibdir[@]|$(pkglibdir)|g' -e 's|@datadir[@]|$(datadir)|g'

$(scripts): %: %.sh
	$(sedit) $< > $@

submit-%: %
	$(sedit) -e "s|@submitscript[@]|$<|g" @srcdir@/submit-wrapper.sh > $@

script_sources = \
	archiver.sh \
	blastn-bare.sh \
	blastn.sh \
	blastp-bare.sh \
	blastp.sh \
	blastx-bare.sh \
	blastx.sh \
	cufflinks.sh \
	cutadapt-bare.sh \
	cutadapt.sh \
	segemehl.sh \
	strace-analyzer.sh \
	tblastn-bare.sh \
	tblastn.sh \
	tophat.sh \
	vcftools-recode.sh \
	vcftools.sh

scripts = $(script_sources:.sh=)

submit_scripts = $(addprefix submit-,$(scripts))

libs = \
	util.sh

CLEANFILES = $(scripts) $(submit_scripts)
EXTRA_DIST = @srcdir@/submit-wrapper.sh $(libs) $(script_sources)
