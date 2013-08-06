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

Tracing
-------

Submit any of the scripts with an additional environment variable `TRACE` set, e.g.:

    qsub -v TRACE=y [submit-args] script [args]

If this environment variable is set, [strace][] will be used to create a compressed system trace of
the main application used in the script. This trace can later be analyzed by using the
[strace-analyzer][] script.


[modules]: http://modules.sourceforge.net/
[pigz]: http://zlib.net/pigz/
[parallel]: http://www.gnu.org/software/parallel/
[strace]: http://strace.sourceforge.net/
[strace-analyzer]: http://clusterbuffer.wordpress.com/strace-analyzer/


---

[![endorse](http://api.coderwall.com/wookietreiber/endorsecount.png)](http://coderwall.com/wookietreiber)
