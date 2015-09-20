
require 'json'

module SbgGlobalSearch
  module GlobalSearch 

   def get_environment_nodes(env=node.chef_environment.downcase)
      real_endpoint = Chef::Config[:chef_server_url].to_s
      real_node_name = Chef::Config[:node_name].to_s
      real_client_key = Chef::Config[:client_key].to_s
      
      #Point the Chef Search client at the appropriate organizations Chef server and load the correct client key
      #If we're searching outside the current organization, and we know where to search
      if env.downcase != node.chef_environment.downcase and node['sbg_global_search']['search'].has_key? env.downcase
        require 'fileutils'
        FileUtils::mkdir_p '/var/chef/cache'
        File.open("/var/chef/cache/searchclient.pem", 'w') { |file| file.write(node['sbg_global_search']['search'][env.downcase]['search_key']) }
        Chef::Config[:client_key] = "/var/chef/cache/searchclient.pem"
        Chef::Config[:node_name] = "searchclient"
        Chef::Config[:verify_api_cert] = false
        Chef::Config[:ssl_verify_mode] = :verify_none
        Chef::Config[:chef_server_url] = node['sbg_global_search']['search'][env.downcase]['endpoint']
      end

      # Search cache per organization
      attr_key = "#{env.downcase}_chef_search_cache"

      unless node.run_state.has_key? attr_key
        node.run_state[attr_key] = [ ]
        namehash = { }

        # simple handler, adds a name field by splitting fqdn
        # also does repeat node filtering - first one wins
        handler = lambda do |n|
            en = n.clone
            en['name'] = en['fqdn'].split('.')[0]
            unless namehash.has_key?( en['name'] )
                node.run_state[attr_key].push( en )
                namehash[en['name']] = true
            end
        end
        # Only pull back the attributes we care about, Chef node JSON can be large
        # and its slow to serialize and deserialize 
        args = {
            :rows   =>  1000,
            :filter_result   =>  {
              :fqdn => [ 'name' ],
              :ipaddress => [ 'ipaddress' ],
              :roles => [ 'role' ]
            },
        }

        # do the search using partial search
        # this incidentially implements paging for >1000 nodes
        Chef::Search::Query.new.search( :node, "chef_environment:#{env.upcase}", args, &handler );
        # and sort those by fqdn
        node.run_state[attr_key].sort! { |m,n| m['name'] <=> n['name'] }
      end
      # Reset the Chef client config back to the original values
      Chef::Config[:chef_server_url] = real_endpoint
      Chef::Config[:node_name] = real_node_name
      Chef::Config[:client_key] = real_client_key
      node.run_state[attr_key]
    end

    # @param [String] role the role for which we want a sorted list of members
    # @return [Array] sorted list of node objects in the current environment which belong to the searched role
    def get_role_member_list( role, env=node.chef_environment.downcase )
        nodes = get_environment_nodes(env.downcase)
        if !nodes
          return []
        end
        nodes.select { |n| n['roles'].include? role }
    end

    # @param [String] role the role for which we want a sorted list of members
    # @return [Array] sorted list of node names in the current environment which belong to the searched role
    def get_role_member_hostnames(role, env=node.chef_environment.downcase)
      get_role_member_list( role, env ).map { |n| n['name'] }
    end
    # @param [String] role the role for which we want a sorted list of members
    # @return [Array] sorted list of node names in the current environment which belong to the searched role
    def get_role_member_ips(role, env=node.chef_environment.downcase)
      get_role_member_list( role, env ).map { |n| n['ipaddress'] }
    end

    # @param [String] role the role for which we want a sorted list of members
    # @return [Array] sorted list of node names in the current environment which belong to the searched role
    def get_role_member_fqdns(role, env=node.chef_environment.downcase)
      get_role_member_list( role, env ).map { |n| n['fqdn'] }
    end

  end
end
