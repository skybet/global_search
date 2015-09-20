name "DEV"
description "SkyBet development environment configuration"
$environment = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
$override = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
$override['env_subdomain']   = "dev"
$override['env_url_snippet'] = "." + $override['env_subdomain']
$override['env_url_subdomain'] = $override['env_subdomain'] + "."

# Optional include attributes from environments/common/site_a.rb - this was needed for some sbg_base recipes
# to function correctly

# Also can put things in which come from other cookbooks but makes no sense to remove coupling just to get vagrant to pass
# the build - e.g. salt master attribute from sbg_salt in sbg_base:whatami
default_attributes(Chef::Mixin::DeepMerge.merge($_default_environment, $environment))
override_attributes($override)

