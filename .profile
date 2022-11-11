 # user environment
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

export GOROOT="/usr/local/go"
if [ -d "$GOROOT/bin" ]; then
    export PATH="$GOROOT/bin:$PATH"
fi

export GOPATH="$HOME/go"
if [ -d "$GOPATH/bin" ]; then
    export PATH="$GOPATH/bin:$PATH"
fi
