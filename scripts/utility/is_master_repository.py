#!/usr/bin/env python

import subprocess
pipe = subprocess.Popen("git config --local --get remote.origin.url", \
              shell=True, stdout=subprocess.PIPE)
result = pipe.stdout.read()
is_master_repository = "LCPQ/quantum_package" in result

if __name__ == "__main__":
    import sys
    if is_master_repository:
        sys.exit(0)
    else:
        sys.exit(-1)
