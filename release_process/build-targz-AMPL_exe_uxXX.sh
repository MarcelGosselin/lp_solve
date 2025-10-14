#!/bin/bash
set -e

. $(dirname "$0")/check_env_vars.sh
requiredEnvVars=("LPSOLVE_WORKSPACE" "LPSOLVE_VERSION" "LPSOLVE_PLATFORM")
assertEnvironmentVariablesAreNotEmpty "${requiredEnvVars[@]}"

TAR_CONTENT_FOLDER=${LPSOLVE_WORKSPACE}/output/AMPL_exe_${LPSOLVE_PLATFORM}
mkdir -p $TAR_CONTENT_FOLDER
TAR_CONTENT_FOLDER=$( realpath $TAR_CONTENT_FOLDER )

cd ${LPSOLVE_WORKSPACE}/extra/AMPL/solvers
if [ "$CC" == "" ]; then
    make -f makefile.u
else # override CC from environment on ux32
    make -f makefile.u CC="$CC"
fi
cd ${LPSOLVE_WORKSPACE}/extra/AMPL/solvers/lpsolve
make -f makefile5stat.u

cp ${LPSOLVE_WORKSPACE}/extra/AMPL/solvers/lpsolve/lpsolve ${TAR_CONTENT_FOLDER}
cp ${LPSOLVE_WORKSPACE}/extra/AMPL/solvers/lpsolve/README ${TAR_CONTENT_FOLDER}
cp ${LPSOLVE_WORKSPACE}/extra/AMPL/solvers/lpsolve/changes ${TAR_CONTENT_FOLDER}
cp ${LPSOLVE_WORKSPACE}/extra/man/AMPL.htm ${TAR_CONTENT_FOLDER}

cd $TAR_CONTENT_FOLDER
tar -czf ${LPSOLVE_WORKSPACE}/lp_solve_${LPSOLVE_VERSION}_AMPL_exe_${LPSOLVE_PLATFORM}.tar.gz *
