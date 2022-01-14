 # user environment
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

export GOPATH="$HOME/SAPDevelop/go"
export GOPRIVATE='github.wdf.sap.corp/*'
export VFLOWPATH="$GOPATH/src/github.wdf.sap.corp/velocity/vflow"
export VSOLUTIONPATH="$GOPATH/src/github.wdf.sap.corp/velocity/vsolution"

if [ -d "$GOPATH/bin" ]; then
    export PATH="$GOPATH/bin:$PATH"
fi
