class NarsilMcp < Formula
  desc "Blazingly fast MCP server for code intelligence"
  homepage "https://github.com/postrv/narsil-mcp"
  version "1.1.2-beta"
  license "MIT OR Apache-2.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2-beta/narsil-mcp-v1.1.2-beta-macos-x86_64.tar.gz"
      sha256 "ad3c6bf7bdb1d990264dca35f6d9fb411e07b489e6b5aa6c48bb72f4345491e7"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2-beta/narsil-mcp-v1.1.2-beta-macos-aarch64.tar.gz"
      sha256 "7073ab2cd60534a13b7c75e5fd2a99cf36f486e554bc1585025c5f699d7729a0"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2-beta/narsil-mcp-v1.1.2-beta-linux-x86_64.tar.gz"
      sha256 "b7a9b16dfd38192f3ee67f160e927bbe7ba55f1bec1b2bb7d0fe7c8a93f7d0da"
    end
  end

  def install
    bin.install "narsil-mcp"
  end

  test do
    # Test that the binary exists and is executable
    assert_match version.to_s, shell_output("#{bin}/narsil-mcp --version")
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
end
