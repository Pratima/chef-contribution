class HtopTestClass < MiniTest::Chef::TestCase

	def test_pkg_installed
		assert system('rpm -qa | grep htop')
        end
end

