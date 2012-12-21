#
#   Portions Copyright (c) 2012 VMware, Inc. All Rights Reserved.
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

include_recipe "hadoop_cluster"

# Install
hadoop_package node[:hadoop][:packages][:journalnode][:name]

include_recipe "hadoop_cluster::hadoop_conf_xml"

# Launch service
set_bootstrap_action(ACTION_START_SERVICE, node[:hadoop][:journalnode_service_name])

is_journalnode_running = system("service #{node[:hadoop][:journalnode_service_name]} status 1>2 2>/dev/null")
service "restart-#{node[:hadoop][:journalnode_service_name]}" do
  service_name node[:hadoop][:journalnode_service_name]
  supports :status => true, :restart => true

  subscribes :restart, resources("template[/etc/hadoop/conf/core-site.xml]"), :delayed
  subscribes :restart, resources("template[/etc/hadoop/conf/hdfs-site.xml]"), :delayed
  subscribes :restart, resources("template[/etc/hadoop/conf/hadoop-env.sh]"), :delayed
  notifies :create, resources("ruby_block[#{node[:hadoop][:journalnode_service_name]}]"), :immediately
end if is_journalnode_running

service "start-#{node[:hadoop][:journalnode_service_name]}" do
  service_name node[:hadoop][:journalnode_service_name]
  action [ :enable, :start ]
  supports :status => true, :restart => true

  notifies :create, resources("ruby_block[#{node[:hadoop][:journalnode_service_name]}]"), :immediately
end

# Register with cluster_service_discovery
provide_service(node[:hadoop][:journalnode_service_name])
