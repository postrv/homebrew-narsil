class NarsilMcp < Formula
  desc "Blazingly fast MCP server for code intelligence"
  homepage "https://github.com/postrv/narsil-mcp"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.1/narsil-mcp-v1.7.1-macos-x86_64.tar.gz"
      sha256 "4eea1c65f7544454549aefe4be43747c92ce8250bc6e5252a5877127399985c0"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.1/narsil-mcp-v1.7.1-macos-aarch64.tar.gz"
      sha256 "fb536977b7992d6ac1bde80fb57f9d78e5691104bd3f7c11d1c9743c85b51d6f"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.1/narsil-mcp-v1.7.1-linux-x86_64.tar.gz"
      sha256 "704a9611b31cfe5675c87f21627466b6a3a1ba1e8bc582bc16764513f383bb36"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.1/narsil-mcp-v1.7.1-linux-aarch64.tar.gz"
      sha256 "ff0b753aac85fcb2166bd8f57bd9d3b8b2a18ccc5b6b64101773c7c28cacd34d"
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
