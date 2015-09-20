name             'sbg_global_search'
maintainer       'Sky Betting and Gaming'
maintainer_email 'you@example.com'
license          'All rights reserved'
description      'Installs/Configures global_search'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'
depends          'chef-vault'
depends          'sbg_base'
depends          'sbg_repo_versions'
depends          'sbg_iptables'

