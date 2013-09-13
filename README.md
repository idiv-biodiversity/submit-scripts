Submit Scripts
==============

This is a collection of ready-to-use submit scripts for high performance computing clusters.

Motivation
----------

Not all users know both their applications and scripting well enough to get the most out of their
applications and to reduce the amount of maintenance they have with their scripts. The submit
scripts provided by this project can be used almost as easy as the applications they are
wrapping. They also consider many pitfalls and provide automatic ways to handle them, some of them
are:

-   Using parameters for the submit scripts themselves greatly reduces the amount of submit scripts
    needed and thus the potential for bit rot, error and maintenance. All provided submit scripts
    accept various arguments to reduce the need to *hard-code* configuration (like the path to the
    input file) in the script. Thus, the submission of the jobs defines them instead of the script
    itself: a submit script should be just a convenient wrapper for the application it executes.

-   Automatically handling the degree of parallelism reduces the amount of misappropriated
    resources. It certainly may happen that users submit jobs with a different degree of parallelism
    than the internal application is using. This may lead to either an overloaded system or an
    under-utilized system. By automatically considering the submission requests these issues can be
    avoided.

-   Handling I/O becomes more and more a problem with the distributed / networked file systems used
    by computing clusters. If an application needs lots of IOPS to read or write a certain block of
    data where this could have been done with fewer IOPS performance might degrade considerably. The
    provided submit scripts are designed to both work around this problem by wrapping reading and
    writing files with better block sizes and working with compressed data as much as possible.

Also, there is a small **Submit Script API** used by most of the scripts to handle common
problems. This API can be used to write additional submit scripts more easily.

Requirements
------------

- a **resource and job management system** (aka *job scheduler* aka *distributed resource management
  system*) to submit the jobs, tested is currently just the *Sun Grid Engine 6.2u5* but similar
  systems / clones should work as well
- most of the (non-standard) software is required to be installed via a functional
  [Environment Modules][modules] installation
- some scripts may require non-standard tools like [pigz][] or [GNU Parallel][parallel]

Supported Applications
----------------------

The following applications are supported:

- blastn
- blastp
- blastx
- cutadapt
- segemehl
- tblastn
- tophat
- vcftools

The following helpful utilities are supported:

- archiver: builds an archive file and verifies it efficiently
- strace-analyzer

Issues, Feature Requests and Contributions
------------------------------------------

You are very welcome to open issues if something does not work the way you like, request features if
you would really like some particular functionality or even better contribute it yourself. Please
use the GitHub facilities [Issues][] and [Pull Requests][] for this.

Installation
============

    git clone git://github.com/wookietreiber/submit-scripts.git
    autoconf
    ./configure --prefix=/path/to/target
    make install


Usage
=====

Since this project relies on a [Environment Modules][modules] installation anyway there is also a
module file:

    module load submit-scripts

There are two ways to submit a job with the provided scripts:

1.  Submit a script directly:

    The general usage to submit a script directly is as follows:

        qsub [submit-args] /path/to/share/submit-scripts/app [app-args]

2.  Execute a submit script wrapper:

        submit-app [app-args]

    Give it submit arguments explicitly:

        SUBMIT_OPTS="submit-args" submit-app [app-args]

    Give it submit arguments implicitly (by setting the shell variable):

        export SUBMIT_OPTS="submit-args"
        submit-app [app-args]

To get help on a specific submit script just execute the wrapper with the `--help` argument:

    submit-app --help

Most scripts have some required arguments, like an input file. All other arguments get passed
directly to the main application used in the script.

Sequential and Parallel Jobs
----------------------------

The degree of parallelism gets chosen automatically by however you submit the script, i.e. if you
request the job to be parallel by say supplying `-pe smp 12` as part of your submit arguments the
application will use 12 threads / processes / cores. All scripts are written so this is done
automatically.

Example tblastn-bare
--------------------

The `tblastn-bare` script has two mandatory arguments, the query and the database, while all other
arguments get supplied directly to `tblastn`, e.g.:

    qsub [submit-args] tblastn-bare query chr1.fa -word_size 3 -outfmt 6 -evalue 10

Alternatively:

    [SUBMIT_OPTS="submit-args"] submit-tblastn-bare query chr1.fa -word_size 3 -outfmt 6 -evalue 10

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
[Issues]: https://github.com/wookietreiber/submit-scripts/issues
[Pull Requests]: https://github.com/wookietreiber/submit-scripts/pulls


---

[![endorse](http://api.coderwall.com/wookietreiber/endorsecount.png)](http://coderwall.com/wookietreiber)
