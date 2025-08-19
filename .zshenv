# Local Scripts
export PATH="$HOME/.local/scripts:$PATH"

# Nodejs
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# GO Environment
export PATH=$PATH:/usr/local/go/bin
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Rust Environment
export PATH="$HOME/.cargo/bin:$PATH"

# ANDROID SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"
export PATH="$HOME/development/flutter/bin:$PATH"
export CHROME_EXECUTABLE="/usr/bin/thorium-browser"

# Solana Cli
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
. "$HOME/.local/share/bob/env/env.sh"