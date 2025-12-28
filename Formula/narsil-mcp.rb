class NarsilMcp < Formula
  desc "Blazingly fast MCP server for code intelligence"
  homepage "https://github.com/postrv/narsil-mcp"
  version "1.1.3"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.3/narsil-mcp-v1.1.3-macos-x86_64.tar.gz"
      sha256 "82ccf9ab77f8dc18b768087ae1b3e5d07feeddacd2923ff484b99d112dca87f1"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.3/narsil-mcp-v1.1.3-macos-aarch64.tar.gz"
      sha256 "5c0eb9808c7a34e4dc907f9fa563c14276264fc67522806d81f4109261288d63"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.3/narsil-mcp-v1.1.3-linux-x86_64.tar.gz"
      sha256 "e0c9fa1892ec24e26357c59678e965286bdea625846debb8ff105c2f621a0fd4"
    end
  end

  def install
    bin.install "narsil-mcp"
  end

  def caveats
    <<~EOS
      To use narsil-mcp with AI assistants:

      Claude Desktop:
        Add to ~/Library/Application Support/Claude/claude_desktop_config.json:
        {
          "mcpServers": {
            "narsil-mcp": {
              "command": "narsil-mcp",
              "args": ["--repos", "/path/to/your/projects"]
            }
          }
        }

      VS Code with Copilot:
        Create .vscode/mcp.json in your workspace:
        {
          "servers": {
            "narsil-mcp": {
              "command": "narsil-mcp",
              "args": ["--repos", "${workspaceFolder}"]
            }
          }
        }

      Cursor:
        Create .cursor/mcp.json in your project:
        {
          "mcpServers": {
            "narsil-mcp": {
              "command": "narsil-mcp",
              "args": ["--repos", "."]
            }
          }
        }

      Documentation: https://github.com/postrv/narsil-mcp
    EOS
  end

  test do
    # Test that the binary exists and is executable
    assert_match version.to_s, shell_output("#{bin}/narsil-mcp --version")
  end
end
