class NarsilMcp < Formula
  desc "Blazingly fast MCP server for code intelligence"
  homepage "https://github.com/postrv/narsil-mcp"
  version "1.1.2"
  license "MIT OR Apache-2.0"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2/narsil-mcp-v1.1.2-macos-x86_64.tar.gz"
      sha256 "cc9382e05007d61a96be0bfaf801a400cdd5ba491ec56c90888dd3020ee99933"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2/narsil-mcp-v1.1.2-macos-aarch64.tar.gz"
      sha256 "1066988c033d258d64a7b3e433a9d8ef055881ccb0761823b84122e7286db642"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.1.2/narsil-mcp-v1.1.2-linux-x86_64.tar.gz"
      sha256 "86f3552ab17ba0829c92a904c3167c3bba858906e117599cb99cfe074b8ec515"
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
