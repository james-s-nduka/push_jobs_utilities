require 'chef'

search_criteria ||= ARGV[0]
env_name ||= ARGV[1]
knife_file_location ||= ARGV[2]
cookbook_name ||= ARGV[3]
timeout ||= ARGV[4].to_i

# search_criteria = "patch_inprogress:true AND chef_environment:globaldev AND (name:rhel_satellite_client-demo-4 OR name:rhel_satellite_client-demo-2)"
# knife_file_location = "/Users/alex/tesco-poc/on-prem-chef-repo/.chef/knife.rb"
# cookbook_name = "yum-tesco"
# timeout = 600

search_criteria2 = "(chef_environment:#{env_name} AND (#{search_criteria}))"

ecode = 0

SLEEP_TIME ||= 15

Chef::Config.from_file(knife_file_location)
Chef::Config[:ssl_verify_mode] = :verify_none
puts "Using Chef Server: #{Chef::Config[:chef_server_url]}"

origin = timeout

puts "Will wait up to #{timeout / 60} minutes for polling to complete..."

puts "Finding nodes with search criteria: #{search_criteria2}..."
index = 0
begin
  index += 1
  # Sleep unless this is our first time through the loop.
  sleep(SLEEP_TIME) unless timeout == origin
  nodes = ::Chef::Search::Query.new.search(:node, search_criteria2)[0]
  if !nodes || nodes.empty?
    # We didn't find any node to deploy. Lets skip this phase!
    puts 'No nodes found. Skipping polling!'
    break
  end

  if timeout == origin
    node_names = nodes.map(&:name)
    puts "Found nodes: #{node_names}"
  end

  complete = []
  inprogress = []
  failed = []
  success = []
  nodes.map do |n|
    name = n.name
    if n[cookbook_name.to_s]
      # puts "Node name=#{name}, inprogress status=#{n["#{cookbook_name}"]['patch_inprogress']}, failed status=#{n["#{cookbook_name}"]['patch_failed']}"
      if n[cookbook_name.to_s]['patch_failed']
        failed << name
        ecode = 1
      else
        if n[cookbook_name.to_s]['patch_inprogress']
          inprogress << name
        else
          success << name
        end
      end
    else
      puts "Node #{n['fqdn']} does not have any #{cookbook_name} cookbook attributes set.  Please check the node has the cookbook in it's run-list"
    end

    complete << (!n[cookbook_name.to_s]['patch_inprogress'] || n[cookbook_name.to_s]['patch_failed'])
  end
  statuses = {}
  statuses['success'] = success if success
  statuses['inprogress'] = inprogress if inprogress
  statuses['failed'] = failed if failed
  node_statuses = {}
  node_statuses['node patch statuses'] = statuses
  puts 'Polling patch status ' + index.to_s + ': ' + node_statuses.to_s

  break if complete.all?
  timeout -= SLEEP_TIME
end while timeout > 0

## If we make it here and we are past our timeout the job timed out.
if timeout <= 0
  puts "ERROR: Timed out after #{origin / 60} minutes waiting for polling to complete. Polling Failed..."
  ecode = 2
end
puts "Ended polling node patch status with exit code: #{ecode}"

exit ecode
