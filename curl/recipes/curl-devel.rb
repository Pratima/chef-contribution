include_recipe "curl::default"

yum_package "curl-devel" do
	arch "x86_64"
end
