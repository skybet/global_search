require 'json'

include_recipe "sbg_global_search::default"

hosts = get_role_member_hostnames 'common'

file "/tmp/hosts" do
  content hosts.to_json
end
