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

# uber
export GOMONOREPO="$HOME/Uber/go-code-sparse"
export MONOREPO_BASE=$GOMONOREPO
export WORKSPACE_ROOT=$GOMONOREPO
export UPANEL="$GOMONOREPO/src/code.uber.internal/people/talent/upanel"
export SCOUTHIRE="$GOMONOREPO/src/code.uber.internal/people/scout-hire"
export DEVPOD_NAME="rkochp.devpod-bra"
