export EDITOR=nvim

# user environment
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.local/scripts" ]; then
    export PATH="$HOME/.local/scripts:$PATH"
fi

export GOROOT="/usr/local/go"
if [ -d "$GOROOT/bin" ]; then
    export PATH="$GOROOT/bin:$PATH"
fi

export GOPATH="$HOME/go"
if [ -d "$GOPATH/bin" ]; then
    export PATH="$GOPATH/bin:$PATH"
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

if [ -f "$HOME/.envsecrets" ]; then
    . "$HOME/.envsecrets"
fi
