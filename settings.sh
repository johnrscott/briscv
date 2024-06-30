# Use this script to source the settings64.sh script from Vivado
# to set up the environment. Modify the path to Xilinx tools and
# the Vivado version depending on your installation.
#
# Before running this script
#
# Run this (including the dot):
#
# . settings.sh

XILINX_PATH=$HOME/tools/Xilinx
VIVADO_VERSION=2023.2
TABBY_CAD_SUITE_PATH=$HOME/opt/tabby

if [[ -z "$YOSYSHQ_LICENSE" ]]; then
    echo "You must define YOSYSHQ_LICENSE=<path to license> before sourcing this script."
else
    . $XILINX_PATH/Vivado/$VIVADO_VERSION/settings64.sh
    . $TABBY_CAD_SUITE_PATH/environment    

    # On Ubuntu 22.04, Vitis 2023.2 cannot find libssl.so.10 and
    # libcrypto.so.10. This adds them to the LD path.
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${XILINX_VITIS}/tps/lnx64/cmake-3.24.2/libs/Rhel/9
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${XILINX_VITIS}/tps/lnx64/cmake-3.3.2/libs/Ubuntu/x86_64-linux-gnu

fi
