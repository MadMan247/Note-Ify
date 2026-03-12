#!/bin/bash

# 1. Establish Absolute Base Directory
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR" || exit 1

echo "====================================="
echo "Note-Ify Linux Setup"
echo "====================================="
echo "Working Directory: $SCRIPT_DIR"
echo "====================================="

# Ask for Discord Token
echo "Step 1: Enter Discord Token"
read -p "Enter your Discord Bot Token (leave blank to skip): " DISCORD_TOKEN
echo "will save to .env if changed"

# Clone Note-Ify
echo "Step 2: Cloning Note-Ify"
if [ ! -d "Note-Ify" ]; then
    git clone https://github.com/Spar3Chang3/Note-Ify.git
    cd Note-Ify || exit 1
    if [ $? -ne 0 ]; then
        echo "Git clone failed."
        exit 1
    fi
else
    cd Note-Ify || exit 1
    git pull
fi

# ONLY update .env if DISCORD_TOKEN has text
if [ -n "$DISCORD_TOKEN" ]; then
    echo "DISCORD_TOKEN=$DISCORD_TOKEN" > .env
    echo "Saved new token to .env"
fi

# Install dependencies and build Note-Ify
echo "Step 3: Installing dependencies and building Note-Ify"
if [ ! -f "package.json" ]; then
    echo "package.json not found. Cannot install dependencies."
    exit 1
fi

echo "Running bun install..."
bun install
if [ $? -ne 0 ]; then
    echo "bun install failed."
    exit 1
fi

echo "Building Note-Ify..."
bun build index.js --compile --outfile noteify
if [ $? -ne 0 ]; then
    echo "Binary Compilation failed."
    exit 1
fi

# Go safely back to the script's base directory
cd "$SCRIPT_DIR" || exit 1

# Clone whisper.cpp
echo "Step 4: Cloning whisper.cpp"
if [ ! -d "whisper.cpp" ]; then
    git clone https://github.com/ggml-org/whisper.cpp.git
    cd whisper.cpp || exit 1
    if [ $? -ne 0 ]; then
        echo "whisper.cpp clone failed."
        exit 1
    fi
else
    cd whisper.cpp || exit 1
    git pull
fi

# Build whisper.cpp
echo "Step 5: Building whisper.cpp"
if ! command -v vulkaninfo &> /dev/null; then
    echo "No vulkan support detected, building standard release..."
    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
else
    echo "Vulkan detected, building with Vulkan support..."
    cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DGGML_VULKAN=1
fi

if [ $? -ne 0 ]; then
    echo "CMake generation failed."
    exit 1
fi

cmake --build build --config Release
if [ $? -ne 0 ]; then
    echo "whisper.cpp build failed."
    exit 1
fi

# Download models
echo "Step 6: Downloading ggml-base.bin"
mkdir -p ./build/bin/Release/models
if [ ! -f "./build/bin/Release/models/ggml-base.en.bin" ]; then
    bash ./models/download-ggml-model.sh base.en
    mv ./models/ggml-base.en.bin ./build/bin/Release/models/ 2>/dev/null || mv ggml-base.en.bin ./build/bin/Release/models/
    if [ $? -ne 0 ]; then
        echo "Model download failed."
    fi
else
    echo "Model already exists. Skipping download."
fi

# Pull Ollama Model
echo "Step 7: Pulling Ollama Model"
ollama pull huihui_ai/qwen3-abliterated:8b-v2

# Safely return to base directory before finishing
cd "$SCRIPT_DIR" || exit 1

echo "====================================="
echo "            Setup Complete"
echo "====================================="
