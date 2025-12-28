class NarsilMcp < Formula
  desc "Blazingly fast MCP server for code intelligence"
  homepage "https://github.com/postrv/narsil-mcp"
  version "1.1.2"
  license "MIT OR Apache-2.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2/narsil-mcp-v1.1.2-macos-x86_64.tar.gz"
      sha256 "a7786f5cdd055735120729bfabf334facaeb053af95af36c5d21c1a8889efa26"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2/narsil-mcp-v1.1.2-macos-aarch64.tar.gz"
      sha256 "d4d3aeb5c671dbc0ec715c7507616e461102f73ffeeeead722626153ae9fc92e"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2/narsil-mcp-v1.1.2-linux-x86_64.tar.gz"
      sha256 "c7eada17a7e30b29e555e547e92e249e9527bc4782160a090bf4ebbc09d8486d"
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
