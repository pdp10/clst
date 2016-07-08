
# clst

### Introduction
This folder includes a set of utilities for managing a cluster with OpenLava LSF platform (http://www.openlava.org/). 

### Installation and first use
In order to use these utilities, the following environmental variables must be added: 
CLST_DIR pointing to this folder
CLST_LIB pointing to lib 

The environmental variable ${CLST_DIR}/bin could be added to your $PATH. 

Before installing openlava the administrator should edit the openlava configuration files in etc/lsf_config . 

In ${CLST_DIR}/bin the scripts
- clst_install_openlava.sh   # install openlava and copy the configuration files to the nodes
- clst_start_openlava.sh     # start the service
- clst_stop_openlava.sh      # stop the service
- clst_test_openlava.sh      # a quick test

provide an easy installation and management of openlava. These script work and are tested with openlava-2.2.

