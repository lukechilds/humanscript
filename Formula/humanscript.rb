class Humanscript < Formula
	desc "A truly natural scripting language"
	homepage "https://github.com/lukechilds/humanscript"
	version "1.0.0"
	url "https://github.com/lukechilds/humanscript/archive/1.0.0.tar.gz"
	sha256 "<update-this>"

	depends_on "openssl"
	depends_on "curl"
	depends_on "jq"

	def install
		bin.install "humanscript"
	end
end