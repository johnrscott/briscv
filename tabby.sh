TABBY_CAD_SUITE_PATH=$HOME/opt/tabby

if [[ -z "$YOSYSHQ_LICENSE" ]]; then
    echo "You must define YOSYSHQ_LICENSE=<path to license> before sourcing this script."
else
    . $TABBY_CAD_SUITE_PATH/environment    
fi
