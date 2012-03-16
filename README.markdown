Tar extraction problem
======================

Overview
--------

When extracting different types of tar archives into a target directory,
we ran into troubles depending on the version of Bash that we were using.
In particular, these were the target platforms to support:

	$ lsb_release -a
	LSB Version:	:core-4.0-amd64:core-4.0-ia32:core-4.0-noarch:graphics-4.0-amd64:graphics-4.0-ia32:graphics-4.0-noarch:printing-4.0-amd64:printing-4.0-ia32:printing-4.0-noarch
	Distributor ID:	CentOS
	Description:	CentOS release 5.7 (Final)
	Release:	5.7
	Codename:	Final
	
	$ bash --version
    GNU bash, version 3.2.25(1)-release (x86_64-redhat-linux-gnu)
    Copyright (C) 2005 Free Software Foundation, Inc.

    ### AND...
	$ lsb_release -a
	Distributor ID:	Ubuntu
	Description:	Ubuntu 10.04.4 LTS
	Release:	10.04
	Codename:	lucid
	
    $ bash --version
	GNU bash, version 4.1.5(1)-release (i486-pc-linux-gnu)
	Copyright (C) 2009 Free Software Foundation, Inc.
	License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>


The problem: 
------------

Extract an archive into a target directory (ie: htdocs)
with the following constraints:

 - Extract directly into the target dir while overwriting files
 - Extract only a selected directory from the archive while supporting:
   - Single top-level directory
   - "tar-bombs" (archives with no top-level dir)
   - Archives where target files reside in multiple top-level dirs
     - with spaces OR
	 - without spaces
   - Archives where selected directory can be selected by wildcards
 - Extraction must work on both target versions of Bash (above)

The main issue is that most solutions for 'multiple dirs with spaces'
and the 'tar-bomb' style (dir-to-extract=NULL) are mutually exclusive 
with one another across Bash versions.
