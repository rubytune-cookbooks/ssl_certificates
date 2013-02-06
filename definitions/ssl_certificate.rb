define :ssl_certificate do
  
  name = params[:name] =~ /\*\.(.+)/ ? "#{$1}_wildcard" : params[:name]
  # gsub is required since databags can't contain dashes
  cert = data_bag_item('certificates', name.gsub(".", "_"))
  
  template "#{node[:ssl_certificates][:path]}/#{name}.crt" do
    source "cert.erb"
    mode "0640"
    cookbook "ssl_certificates"
    owner "root"
    group "www-data"
    variables 'cert' => cert["crt"]
  end

  template "#{node[:ssl_certificates][:path]}/#{name}.key" do
    source "cert.erb"
    mode "0640"
    cookbook "ssl_certificates"
    owner "root"
    group "www-data"
    variables 'cert' => cert['key']
  end

  if cert['intermediate']
    template "#{node[:ssl_certificates][:path]}/#{name}_combined.crt" do
      source "cert.erb"
      mode "0640"
      cookbook "ssl_certificates"
      owner "root"
      group "www-data"
      variables 'cert' => cert['intermediate'] ? cert['crt'] + cert['intermediate'] : cert['crt']
    end
  end
end
