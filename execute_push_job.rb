require 'chef'

search_criteria ||= ARGV[0]
env_name ||= ARGV[1]
knife_file_location ||= ARGV[2]
push_job_name ||= ARGV[3]
timeout ||= ARGV[4].to_i

# search_criteria = "name:rhel_satellite_client-demo-4 OR name:rhel_satellite_client-demo-2"
# env_name = globaldev
# knife_file_location = "/Users/alex/tesco-poc/on-prem-chef-repo/.chef/knife.rb"
# push_job_name = "chef-client"
# timeout = 600

search_criteria2 = "(chef_environment:#{env_name} AND (#{search_criteria}))"

ecode = 0

SLEEP_TIME ||= 15
PUSH_SLEEP_TIME ||= 5

Chef::Config.from_file(knife_file_location)
Chef::Config[:ssl_verify_mode] = :verify_none
puts "Using Chef Server: #{Chef::Config[:chef_server_url]}"

env = ::Chef::Search::Query.new.search(:environment, "name:#{env_name}")[0]
puts 'Deploying to nodes in the Chef Environment: ' + env.to_s

origin = timeout

puts "Will wait up to #{timeout / 60} minutes for deployment to complete..."

begin
  # Sleep unless this is our first time through the loop.
  sleep(SLEEP_TIME) unless timeout == origin

  # Find any dependency/app node
  puts "Finding nodes with search criteria: #{search_criteria2}..."
  nodes = ::Chef::Search::Query.new.search(:node, search_criteria2)[0]
  if !nodes || nodes.empty?
    # We didn't find any node to deploy. Lets skip this phase!
    puts 'No nodes found. Skipping deployment!'
    break
  end
  node_names = nodes.map(&:name)
  puts "Found nodes: #{node_names}"

  chef_server_rest = Chef::ServerAPI.new(Chef::Config[:chef_server_url])

  # Kick off command via push.
  puts "Triggering #{push_job_name} on nodes with Chef Push Jobs..."

  req = {
    'command' => push_job_name.to_s,
    'nodes' => node_names
  }

  resp = chef_server_rest.post('/pushy/jobs', req)
  job_uri = resp['uri']

  unless job_uri
    # We were not able to start the push job.
    puts "Could not start push job. Will try again in #{SLEEP_TIME} seconds..."
    next
  end

  puts "Started push job with id: #{job_uri[-32, 32]}"
  previous_state = 'initialized'
  index = 0
  begin
    index += 1
    sleep(PUSH_SLEEP_TIME) unless previous_state == 'initialized'
    job = chef_server_rest.get_rest(job_uri)
    puts 'Polling Job ' + index.to_s + ': ' + job.to_s
    case job['status']
    when 'new'
      finished = false
      state = 'initialized'
    when 'voting'
      finished = false
      state = job['status']
    else
      total = job['nodes'].values.inject(0) do |sum, n|
        sum + n.length
      end

      in_progress = job['nodes'].keys.inject(0) do |sum, status|
        nodes = job['nodes'][status]
        sum + (%w(new voting running).include?(status) ? 1 : 0)
      end

      if job['status'] == 'running'
        finished = false
        state = job['status'] +
                " (#{in_progress}/#{total} in progress) ..."
      else
        finished = true
        state = job['status']
      end
    end
    if state != previous_state
      puts "Push Job Status: #{state}"
      previous_state = state
    end

    ## Check for success
    if finished && job['nodes']['succeeded'] &&
       job['nodes']['succeeded'].size == node_names.size
      puts "Deployment complete in #{(origin - timeout) / 60} minutes. Deploy Successful!"
      break
    elsif finished == true && job['nodes']['crashed']
      puts 'Deployment return on the following node with statuses: '
      puts " => Crashed or rebooting: #{job['nodes']['crashed']}." if job['nodes']['crashed']
      break
    elsif finished == true && job['nodes']['failed'] || job['nodes']['unavailable']
      puts 'Deployment failed on the following node with statuses: '
      puts " => Succeeded: #{job['nodes']['succeeded']}." if job['nodes']['succeeded']
      puts " => Failed: #{job['nodes']['failed']}." if job['nodes']['failed']
      puts " => Crashed or rebooting: #{job['nodes']['crashed']}." if job['nodes']['crashed']
      puts " => Unavailable: #{job['nodes']['unavailable']}." if job['nodes']['unavailable']
      ecode = 1
      break
    end
    timeout -= PUSH_SLEEP_TIME
  end until timeout <= 0

  break if finished

  ## If we make it here and we are past our timeout the job timed out
  ## waiting for the push job.
  if timeout <= 0
    puts "ERROR: Timed out after #{origin / 60} minutes waiting for push job. Deploy Failed..."
    ecode = 2
    break
  end

  timeout -= SLEEP_TIME
end while timeout > 0

## If we make it here and we are past our timeout the job timed out.
if timeout <= 0
  puts "ERROR: Timed out after #{origin / 60} minutes waiting for deployment to complete. Deploy Failed..."
  ecode = 2
end
puts "Ended push job with exit code #{ecode}"

exit ecode
