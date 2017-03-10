require 'etc'

id = 'volgactf-org'

fqdn = node[id]['fqdn']
base_dir = ::File.join('/var/www', fqdn)
is_development = node.chef_environment.start_with?('development')
instance_user = node[id]['user']
instance_group = ::Etc.getgrgid(::Etc.getpwnam(instance_user).gid).name

directory base_dir do
  owner instance_user
  group instance_group
  mode 0755
  recursive true
  action :create
end

logs_dir = ::File.join(base_dir, 'logs')

directory logs_dir do
  owner instance_user
  group instance_group
  mode 0755
  recursive true
  action :create
end

tls_certificate fqdn do
  action :deploy
end

ngx_cnf = "#{fqdn}.conf"
tls_item = ::ChefCookbook::TLS.new(node).certificate_entry(fqdn)

template ::File.join(node['nginx']['dir'], 'sites-available', ngx_cnf) do
  source 'main.conf.erb'
  mode 0644
  notifies :reload, 'service[nginx]', :delayed
  variables(
    fqdn: fqdn,
    redirect_fqdn: node[id]['redirect_fqdn'],
    ssl_certificate: tls_item.certificate_path,
    ssl_certificate_key: tls_item.certificate_private_key_path,
    hsts_max_age: node[id]['hsts_max_age'],
    access_log: ::File.join(logs_dir, 'nginx_access.log'),
    error_log: ::File.join(logs_dir, 'nginx_error.log'),
    oscp_stapling: !is_development,
    scts: !is_development,
    scts_dir: tls_item.scts_dir,
    hpkp: !is_development,
    hpkp_pins: tls_item.hpkp_pins,
    hpkp_max_age: node[id]['hpkp_max_age']
  )
  action :create
end

nginx_site ngx_cnf
