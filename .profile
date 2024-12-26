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

if [ -d "/usr/local/go" ]; then
    export GOROOT="/usr/local/go"
    export PATH="$GOROOT/bin:$PATH"
fi

if [ -d "$HOME/go" ]; then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# uber
if [ -d "$HOME/go-code" ]; then
    export GOMONOREPO="$HOME/go-code"
    export MONOREPO_BASE=$GOMONOREPO
    export WORKSPACE_ROOT=$GOMONOREPO
    export UPANEL="$GOMONOREPO/src/code.uber.internal/people/talent/upanel"
    export SCOUTHIRE="$GOMONOREPO/src/code.uber.internal/people/scout-hire"
    export CAREERS="$GOMONOREPO/src/code.uber.internal/people/careers"
fi

if [ -d "$HOME/web-code" ]; then
    export WEBMONOREPO="$HOME/web-code"
    export MONOREPO_BASE=$WEBMONOREPO
    export WORKSPACE_ROOT=$WEBMONOREPO
    export UPANELWEB="$WEBMONOREPO/src/platform/people/talent/upanel-web"
    export SCOUTFUSION="$WEBMONOREPO/src/platform/people/talent/scout-fusion"
    export CAREERSFUSION="$WEBMONOREPO/src/platform/people/talent/careers-fusion"
fi


export DEVPOD_GO="rkochp-go.devpod-bra"
export DEVPOD_WEB="rkochp-web.devpod-bra"
