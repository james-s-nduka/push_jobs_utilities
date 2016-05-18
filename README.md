# Introduction

This repository contains a set of ruby scripts to help execute push jobs from Jenkins and also then test the status of a node's attribtue to check whether a reboot is still in progress or not.  The scripts are:

  * `execute_push_job.rb`
  * `poll_patching_nodes.rb`

## Requirements
  - Chef Client or Chef DK version 12 or above

## Execute Push Job Usage

The script requires 4 arguments when invoking it:
  - **search_criteria** - The search pattern to find Chef nodes. e.g.: `role:role_name AND recipe:cookbook_name::recipe_name`
  - **environment_name** - The environment name to be using in the search pattern to find Chef nodes. e.g.: `uat`, `ppe` or `til`
  - **chef_config_file_location** - The location of the knife.rb or client.rb configuration file. e.g.: `/Users/james/tesco-poc/on-prem-chef-repo/.chef/knife.rb`
  - **push_job_name** - The name of the push job command to invoke. e.g.: `chef-client`
  - **timeout** - Timeout, in seconds, before polling the push job fails. e.g.: `600`

### Example Command
```
/opt/chefdk/embedded/bin/ruby execute_push_job.rb "name:rhel_satellite_client-demo-2 OR name:rhel_satellite_client-demo-4" "uat" "/Users/tesco-user/chef-repo/.chef/knife.rb" "chef-client" 600
```

### Exit Codes

  - **0** - Success
  - **1** - At least one node has a node job status of failed or unavailable
  - **2** - Push job polling timed out

### Example Output
```
Using Chef Server: https://52.50.93.12/organizations/tesco-poc
Deploying to nodes in the Chef Environment: [#<Chef::Environment:0x007f80f30772d8 @name="uat", @description="This is the uat environment.", @default_attributes={"wsus_client"=>{"wsus_server"=>"http://DVUKWDCWSCM001.dev.global.xxxx.org:8530", "update_group"=>"all", "no_reboot_with_logged_users"=>false, "reboot"=>{"auto_restart"=>true, "visual_warning"=>false}}, "yum"=>{"auto_restart"=>false, "yum_timeout"=>3600}}, @override_attributes={}, @cookbook_versions={"chef-client"=>"= 4.3.3", "push-jobs"=>"= 2.6.4", "wsus_client"=>"= 0.1.4", "yum"=>"= 0.1.1", "gemrc-tesco"=>"= 0.0.1"}, @chef_server_rest=nil>]
Will wait up to 10 minutes for deployment to complete...
Finding nodes with search criteria: (chef_environment:_default AND (recipe:test_reboot))...
Found nodes: ["vm-patching-testnode", "vm-patching-testnode2"]
Triggering chef-client on nodes with Chef Push Jobs...
Started push job with id: 44a4012599e1e7d9e717443497cac5bd
Polling Job 1: {"nodes"=>{"running"=>["vm-patching-testnode2", "vm-patching-testnode"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Push Job Status: running (1/2 in progress) ...
Polling Job 2: {"nodes"=>{"running"=>["vm-patching-testnode2", "vm-patching-testnode"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 3: {"nodes"=>{"running"=>["vm-patching-testnode2", "vm-patching-testnode"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 4: {"nodes"=>{"running"=>["vm-patching-testnode2", "vm-patching-testnode"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 5: {"nodes"=>{"running"=>["vm-patching-testnode2", "vm-patching-testnode"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 6: {"nodes"=>{"running"=>["vm-patching-testnode2", "vm-patching-testnode"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 7: {"nodes"=>{"running"=>["vm-patching-testnode2", "vm-patching-testnode"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 8: {"nodes"=>{"running"=>["vm-patching-testnode2", "vm-patching-testnode"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 9: {"nodes"=>{"crashed"=>["vm-patching-testnode"], "running"=>["vm-patching-testnode2"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 10: {"nodes"=>{"crashed"=>["vm-patching-testnode"], "running"=>["vm-patching-testnode2"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 11: {"nodes"=>{"crashed"=>["vm-patching-testnode"], "running"=>["vm-patching-testnode2"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 12: {"nodes"=>{"crashed"=>["vm-patching-testnode"], "running"=>["vm-patching-testnode2"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 13: {"nodes"=>{"crashed"=>["vm-patching-testnode"], "running"=>["vm-patching-testnode2"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"running", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:11:14 GMT"}
Polling Job 14: {"nodes"=>{"crashed"=>["vm-patching-testnode", "vm-patching-testnode2"]}, "id"=>"44a4012599e1e7d9e717443497cac5bd", "command"=>"chef-client", "status"=>"complete", "run_timeout"=>3600, "created_at"=>"Wed, 11 May 2016 10:11:14 GMT", "updated_at"=>"Wed, 11 May 2016 10:12:15 GMT"}
Push Job Status: complete
Deployment return on the following node with statuses: 
 => Crashed or rebooting: ["vm-patching-testnode", "vm-patching-testnode2"].
Ended push job with exit code 0
```

## Poll Patching Nodes Usage

The script requires 4 arguments when invoking it:
  - **search_criteria** - The search pattern to find Chef nodes. e.g.: `role:role_name AND recipe:cookbook_name::recipe_name`
  - **environment_name** - The environment name to be using in the search pattern to find Chef nodes. e.g.: `uat`, `pre-prod` or `prod`
  - **chef_config_file_location** - The location of the knife.rb or client.rb configuration file. e.g.: `/Users/james/poc/on-prem-chef-repo/.chef/knife.rb`
  - **cookbook_name** - The cookbook name that has the attributes to check, either `yum` or `wsus_client` 
  - **timeout** - Timeout, in seconds, before polling the patching status fails. e.g.: `600`

### Example Command
```
/opt/chefdk/embedded/bin/ruby poll_patching_nodes.rb "name:rhel_satellite_client-demo-2 OR name:rhel_satellite_client-demo-4" "uat" "/Users/james/chef-repo/.chef/knife.rb" "yum" 600
```

### Exit Codes

  - **0** - Success
  - **1** - At least one node has a patch status of failed
  - **2** - Polling timed out

### Example Output
```
Using Chef Server: https://52.50.93.12/organizations/poc
Will wait up to 10 minutes for polling to complete...
Finding nodes with search criteria: (chef_environment:_default AND (recipe:test_reboot))...
Found nodes: ["vm-patching-testnode", "vm-patching-testnode2"]
Polling patch status 1: {"node patch statuses"=>{"inprogress"=>["vm-patching-testnode", "vm-patching-testnode2"]}}
Polling patch status 2: {"node patch statuses"=>{"inprogress"=>["vm-patching-testnode", "vm-patching-testnode2"]}}
Polling patch status 3: {"node patch statuses"=>{"inprogress"=>["vm-patching-testnode", "vm-patching-testnode2"]}}
Polling patch status 4: {"node patch statuses"=>{"inprogress"=>["vm-patching-testnode", "vm-patching-testnode2"]}}
Polling patch status 5: {"node patch statuses"=>{"success"=>["vm-patching-testnode"], "inprogress"=>["vm-patching-testnode2"]}}
Polling patch status 6: {"node patch statuses"=>{"success"=>["vm-patching-testnode"], "inprogress"=>["vm-patching-testnode2"]}}
Polling patch status 7: {"node patch statuses"=>{"success"=>["vm-patching-testnode", "vm-patching-testnode2"]}}
Ended polling node patch status with exit code: 0
```
