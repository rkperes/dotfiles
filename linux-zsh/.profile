 # user environment
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

### Uber stuff
export GOMONOREPO="$HOME/Uber/go-code"
export MONOREPO_BASE=$GOMONOREPO
export UPANEL="$GOMONOREPO/src/code.uber.internal/people/talent/upanel"
