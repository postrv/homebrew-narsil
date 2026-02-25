class NarsilMcp < Formula
  desc "Blazingly fast MCP server for code intelligence"
  homepage "https://github.com/postrv/narsil-mcp"
  version "1.6.1"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.6.1/narsil-mcp-v1.6.1-macos-x86_64.tar.gz"
      sha256 "01271583f510eedc6bde87c3ca891989c3be2ffab4e9eaf9b84bbf86d55ab11c"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.6.1/narsil-mcp-v1.6.1-macos-aarch64.tar.gz"
      sha256 "1074c554f66a18416c0b9c5cc4218b0460ab05933022b0b6a4c80f185ce835f0"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.6.1/narsil-mcp-v1.6.1-linux-x86_64.tar.gz"
      sha256 "4c3a3080ef9a348d48a667479c6ab01a0dd46895e9a64aa975bdce5c460982ab"
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
