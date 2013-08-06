Submit Scripts
==============

This is a collection of ready-to-use submit scripts for high performance computing clusters.

Requirements
------------

- a **resource and job management system** (aka *job scheduler* aka *distributed resource management
  system*) to submit the jobs, tested is currently just the *Sun Grid Engine 6.2u5* but similar
  systems / clones should work as well
- most of the (non-standard) software is required to be installed via a functional
  [Environment Modules][modules] installation
- some scripts may require non-standard tools like [pigz][] or [GNU Parallel][parallel]


Usage
=====

The general usage is, of course, as follows:

    qsub [submit-args] script [script-args]

To get help on a specific submit script just execute it directly (do not submit it) with only the
`--help` argument:

    bash script --help

Most scripts have some required arguments, like an input file. All other arguments get passed
directly to the main application used in the script.

Sequential and Parallel Jobs
----------------------------

The degree of parallelism gets chosen automatically by however you submit the script, i.e. if you
request the job to be parallel by say supplying `-pe smp 12` as part of your submit arguments the
application will use 12 threads / processes / cores. All scripts are written so this is done
automatically.

Example tblastn
---------------

The `tblastn` script has two mandatory arguments, the query and the database, while all other
arguments get supplied directly to `tblastn`, e.g.:

    qsub [submit-args] tblastn-bare query chr1.fa -word_size 3 -outfmt 6 -evalue 10

- `query` becomes the input query to `tblastn`
- `chr1.fa` becomes the database
- the degree of parallelism gets chosen automatically (see above)
- all other arguments `-word_size 3 -outfmt 6 -evalue 10` get passed to `tblastn` directly

Thus, the resulting `tblastn` call will be:

    tblastn -num_threads ${NSLOTS:-1} -query query -db chr1.fa -word_size 3 -outfmt 6 -evalue 10

Tracing
-------

Submit any of the scripts with an additional environment variable `TRACE` set, e.g.:

    qsub -v TRACE=y [submit-args] script [args]

If this environment variable is set, [strace][] will be used to create a compressed system trace of
the main application used in the script. This trace can later be analyzed by using the
[strace-analyzer][] script. Since these traces may be rather large in terms of file size, the traces
are always compressed. Since analyzing the traces might take some time, there is also a ready-to-use
strace-analyzer submit script:

    qsub [submit-args] strace-analyzer /path/to/trace.gz


[modules]: http://modules.sourceforge.net/
[pigz]: http://zlib.net/pigz/
[parallel]: http://www.gnu.org/software/parallel/
[strace]: http://strace.sourceforge.net/
[strace-analyzer]: http://clusterbuffer.wordpress.com/strace-analyzer/


---

[![endorse](http://api.coderwall.com/wookietreiber/endorsecount.png)](http://coderwall.com/wookietreiber)
