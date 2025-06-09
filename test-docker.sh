#!/bin/bash

# Test script for mcp-language-server Docker build
set -e

echo "🐳 Testing mcp-language-server Docker build..."

# Build the main Docker image
echo "📦 Building main Docker image..."
docker build -t mcp-language-server .

# Test that the binary is available
echo "🔍 Testing binary availability..."
docker run --rm mcp-language-server --help > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Binary is working"
else
    echo "❌ Binary test failed"
    exit 1
fi

# Test language servers are installed
echo "🔍 Testing language servers..."

# Test Java (jdtls)
echo "  Testing Java language server..."
docker run --rm mcp-language-server sh -c "command -v jdtls" > /dev/null
if [ $? -eq 0 ]; then
    echo "  ✅ Java language server (jdtls) is available"
else
    echo "  ❌ Java language server test failed"
    exit 1
fi

# Test Python (pyright)
echo "  Testing Python language server..."
docker run --rm mcp-language-server sh -c "command -v pyright-langserver" > /dev/null
if [ $? -eq 0 ]; then
    echo "  ✅ Python language server (pyright) is available"
else
    echo "  ❌ Python language server test failed"
    exit 1
fi

# Test Rust (rust-analyzer)
echo "  Testing Rust language server..."
docker run --rm mcp-language-server sh -c "command -v rust-analyzer" > /dev/null
if [ $? -eq 0 ]; then
    echo "  ✅ Rust language server (rust-analyzer) is available"
else
    echo "  ❌ Rust language server test failed"
    exit 1
fi

# Test with docker-compose if available
if command -v docker-compose > /dev/null; then
    echo "🔍 Testing docker-compose configuration..."
    docker-compose config > /dev/null
    if [ $? -eq 0 ]; then
        echo "✅ docker-compose configuration is valid"
    else
        echo "❌ docker-compose configuration test failed"
        exit 1
    fi
fi

# Optionally test the extended Go image if Dockerfile.golang exists
if [ -f "Dockerfile.golang" ]; then
    echo "📦 Building extended Go image..."
    docker build -f Dockerfile.golang -t mcp-language-server-golang .

    echo "🔍 Testing Go language server..."
    docker run --rm mcp-language-server-golang sh -c "command -v gopls" > /dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Go language server (gopls) is available in extended image"
    else
        echo "❌ Go language server test failed in extended image"
        exit 1
    fi
fi

echo "🎉 All Docker tests passed!"
echo ""
echo "Usage examples:"
echo "  docker run --rm -i -v \"\$(pwd):/workspace\" mcp-language-server --workspace /workspace --lsp rust-analyzer"
echo "  docker run --rm -i -v \"\$(pwd):/workspace\" mcp-language-server --workspace /workspace --lsp pyright-langserver -- --stdio"
echo "  docker run --rm -i -v \"\$(pwd):/workspace\" mcp-language-server --workspace /workspace --lsp jdtls -- -data /tmp/jdtls-workspace"
