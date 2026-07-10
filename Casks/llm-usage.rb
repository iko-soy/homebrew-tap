cask "llm-usage" do
  version :latest
  sha256 :no_check

  url "https://github.com/ilyakooo0/llm-usage/releases/latest/download/LLMUsage-latest.zip",
      verified: "github.com/ilyakooo0/llm-usage/"
  name "LLM Usage"
  desc "macOS menu bar app to monitor Claude and Ollama LLM subscription usage limits"
  homepage "https://github.com/ilyakooo0/llm-usage"

  app "LLMUsage.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/LLMUsage.app"],
                   sudo: false
  end
end