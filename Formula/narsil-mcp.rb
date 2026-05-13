class NarsilMcp < Formula
  desc "Blazingly fast MCP server for code intelligence"
  homepage "https://github.com/postrv/narsil-mcp"
  version "1.7.0"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.0/narsil-mcp-v1.7.0-macos-x86_64.tar.gz"
      sha256 "ec143e76654f926b6a1f466b5533b4e178b7e4b21460f052aad5def106ad2483"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.0/narsil-mcp-v1.7.0-macos-aarch64.tar.gz"
      sha256 "a838ffe5d931645191b9c26e7daba9e8ab12042325adf293c881cb458baa5bee"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.0/narsil-mcp-v1.7.0-linux-x86_64.tar.gz"
      sha256 "46986fe312f6fc1bb5fd57d028ee007a321a810084b7e0a6c6c66b337291f4f0"
    elsif Hardware::CPU.arm?
      url "https://github.com/postrv/narsil-mcp/releases/download/v1.7.0/narsil-mcp-v1.7.0-linux-aarch64.tar.gz"
      sha256 "ef79328cf397f21a5ab24b9e932f0254043c9e5672bf7b9df66229fc44c76026"
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
