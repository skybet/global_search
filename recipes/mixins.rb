#
# Cookbook Name:: sbg_base
# Recipe:: mixins
#
# Copyright 2013, Sky Betting and Gaming
#
# All rights reserved - Do Not Redistribute
#
# Somewhere to apply mixins so we dont have to do it whenever we want to use one
#
Chef::Recipe.send( :include, SbgGlobalSearch::GlobalSearch )
