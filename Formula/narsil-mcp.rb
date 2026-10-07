class NarsilMcp < Formula
  desc "Blazingly fast MCP server for code intelligence"
  homepage "https://github.com/postrv/narsil-mcp"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.2/narsil-mcp-v1.7.2-macos-x86_64.tar.gz"
      sha256 "5736177aaa6d3d5da9108978d7c6342f5b8d12c75948ddbda8a900be09a9d553"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.2/narsil-mcp-v1.7.2-macos-aarch64.tar.gz"
      sha256 "f029c72e8e5b6225701cb3705827ae0ed2d414afb21ea670c45a17d83043d536"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.2/narsil-mcp-v1.7.2-linux-x86_64.tar.gz"
      sha256 "f12be877f6dc9f067cd997920ba91408ef985fa94dbe7cf4c3d6b65270f591e4"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.2/narsil-mcp-v1.7.2-linux-aarch64.tar.gz"
      sha256 "52b717dff055c6551254127344cf1dd9852cc5eff47c204dabe8d0371959580c"
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
