# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.7.2"

require 'mkmf'
require 'fileutils'
require 'erb'
require 'ostruct'
 
# Make the MakeMakefile logger write file output to null.
# Probably requires ruby >= 1.9.3
module MakeMakefile::Logging
  @logfile = File::NULL
end

# check all environment variables
abort 'AWS_ACCESS_KEY_ID environment variable needs to be set' if ENV['AWS_ACCESS_KEY_ID'].nil?
abort 'AWS_SECRET_ACCESS_KEY environment variable needs to be set' if ENV['AWS_SECRET_ACCESS_KEY'].nil?
abort 'GITHUB_CLIENT_ID environment variable needs to be set' if ENV['GITHUB_CLIENT_ID'].nil?
abort 'GITHUB_CLIENT_KEY environment variable needs to be set' if ENV['GITHUB_CLIENT_KEY'].nil?
abort 'HIPCHAT_V1_TOKEN environment variable needs to be set' if ENV['HIPCHAT_V1_TOKEN'].nil?
abort 'GITHUB_ACCESS_TOKEN environment variable needs to be set' if ENV['GITHUB_ACCESS_TOKEN'].nil?

def render(templatepath, destinationpath, variables)
  if File.file?(templatepath)
    template = File.open(templatepath, "rb").read
    content = ERB.new(template).result(OpenStruct.new(variables).instance_eval { binding })
    outputpath = destinationpath.end_with?('/') ? "#{destinationpath}/#{File.basename(templatepath, '.erb')}" : destinationpath
    FileUtils.mkdir_p(File.dirname(outputpath))
    File.open(outputpath, "wb") { |f| f.write(content) }
  end
end

def hostname 
  'pipelet.kubeme.io'
end 

# required plugins:
required_plugins = %w(vagrant-aws vagrant-triggers promise highline)

required_plugins.each do |plugin|
  need_restart = false
  unless Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    need_restart = true
  end
  exec "vagrant #{ARGV.join(' ')}" if need_restart
end

Vagrant::configure(VAGRANTFILE_API_VERSION) do |config|

  # install tools and download certs, if needed
  config.trigger.before [:up, :provision] do
    info 'Getting ssl certs'
    run "sudo pip install awscli" if find_executable('aws').nil?
    run "aws s3 cp s3://sundry-automata/certs/pipelet/pipelet.kubeme.io.key #{File.join(File.dirname(__FILE__), 'config/nginx/certs/')}" 
    run "aws s3 cp s3://sundry-automata/certs/pipelet/pipelet.kubeme.io.crt #{File.join(File.dirname(__FILE__), 'config/nginx/certs/')}"
    info 'Getting ssh keys'
    run "aws s3 cp s3://sundry-automata/keys/jenkins/id_rsa #{File.join(File.dirname(__FILE__), 'config/jenkins/keys/')}" 
    run "aws s3 cp s3://sundry-automata/keys/jenkins/id_rsa.pub #{File.join(File.dirname(__FILE__), 'config/jenkins/keys/')}"
    info 'Installing ssh keys'
    run "mkdir -p #{File.join(Dir.home, '.ssh', 'keys', hostname)}"
    run "cp -f #{File.join(File.dirname(__FILE__), 'config', 'jenkins', 'keys', 'id_rsa')} #{File.join(Dir.home, '.ssh', 'keys', hostname)}"
    run "cp -f #{File.join(File.dirname(__FILE__), 'config', 'jenkins', 'keys', 'id_rsa.pub')} #{File.join(Dir.home, '.ssh', 'keys', hostname)}"
    run "chmod 400 #{File.join(Dir.home, '.ssh', 'keys', hostname, 'id_rsa')}"
    run "ssh-add -K #{File.join(Dir.home, '.ssh', 'keys', hostname, 'id_rsa')}"
    info 'Rendering templates'
    render(
      File.join('templates', 'systemd.config.erb'), 
      File.join('.vagrant', 'user-data'), 
      { 
        :hostname => hostname, 
        :jenkins_ssh_key => File.read(File.join('config', 'jenkins', 'keys', 'id_rsa.pub')) 
      }
    )

    render(
      File.join('templates', 'config.xml.erb'), 
      File.join('config', 'data_volume', 'rendered', 'configs', 'config.xml'), 
      { 
        :github_client_id => ENV['GITHUB_CLIENT_ID'], 
        :github_client_key => ENV['GITHUB_CLIENT_KEY'] 
      }
    )

    render(
      File.join('templates', 'jenkins.plugins.hipchat.HipChatNotifier.xml.erb'), 
      File.join('config', 'data_volume', 'rendered', 'configs', 'jenkins.plugins.hipchat.HipChatNotifier.xml'), 
      { 
        :hipchat_api_token => ENV['HIPCHAT_V1_TOKEN']
      }
    )

    render(
      File.join('templates', 'org.jenkinsci.plugins.ghprb.GhprbTrigger.xml.erb'), 
      File.join('config', 'data_volume', 'rendered', 'configs', 'org.jenkinsci.plugins.ghprb.GhprbTrigger.xml'), 
      { 
        :github_access_token => ENV['GITHUB_ACCESS_TOKEN']
      }
    )

    render(
      File.join('templates', 'credentials.erb'), 
      File.join('config', 'jenkins', 'credentials'), 
      { 
        :aws_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :aws_secret => ENV['AWS_SECRET_ACCESS_KEY']
      }
    )
  end

  # clean up downloaded certs
  config.trigger.after [:up, :provision, :destroy] do
    run "rm -rf #{File.join(File.dirname(__FILE__), 'config/nginx/certs')}"
    run "rm -rf #{File.join(File.dirname(__FILE__), 'config/jenkins/keys')}" 
  end

  config.vm.define :pipelet do |pipelet|
    pipelet.vm.box      = 'CoreStable'
    pipelet.vm.box_url  = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
    pipelet.vm.hostname = hostname
    
    # folders
    pipelet.vm.synced_folder ".", "/vagrant", disabled: true
    pipelet.vm.synced_folder "config", "/opt/pipelet/config"

    pipelet.vm.provider :aws do |aws, override|
      aws.access_key_id     = ENV['AWS_ACCESS_KEY_ID']
      aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      aws.ami               = 'ami-67427157' # CoreOS Stable, PV 64bit us-west-2
      aws.instance_type     = 'm3.large'
      aws.keypair_name      = 'pipelet'
      aws.region            = 'us-west-2'   
      aws.security_groups   = [ 'sg-e23fdb86' ] # pipelet sec group
      aws.subnet_id         = 'subnet-eab4d28f'
      aws.elastic_ip        = '52.24.112.56' # eipalloc-f370d196

      # To mount EBS volumes
      aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 100 }]

      # core os userdata
      
      aws.user_data = promise { File.read(File.join('.vagrant', 'user-data')) }

      aws.tags = {
        'Name' => 'Samsung AG Pipelet',
        'Description' => 'Instance running a docker-managed jenkins server.'
      }

      override.ssh.username = 'core'
      override.ssh.private_key_path = File.join(Dir.home, '.ssh', 'keys', hostname, 'id_rsa')
      override.ssh.insert_key = false
      override.nfs.functional = false
    end

    # Install docker and jenkins and run containers
    pipelet.vm.provision "docker" do |d|

      # jenkins data volume
      d.build_image '/opt/pipelet/config/data_volume',
        args: '-t samsung_ag/jenkins-data'

      # jenkins master
      d.build_image "/opt/pipelet/config/jenkins",
        args: '-t samsung_ag/jenkins-server'

      # jenkins master
      d.build_image '/opt/pipelet/config/backup',
        args: '-t samsung_ag/jenkins-backup'

      # data volume
      d.run 'jenkins-data',
        daemonize: true,
        image: 'samsung_ag/jenkins-data'

      # backup container
      d.run 'jenkins-backup',
        daemonize: true,
        image: 'samsung_ag/jenkins-backup',
        cmd: 's3://pipelet 60 /var/jenkins_home/jobs/',
        args: "--volumes-from jenkins-data -e AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY_ID']} -e AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_ACCESS_KEY']}" #--priveleged ?

      # official nginx image
      d.run 'nginx',
        daemonize: true,
        image: 'nginx',
        args: '-v /tmp/nginx:/etc/nginx/conf.d -p 80:80 -p 443:443 -v /opt/pipelet/config/nginx/certs:/etc/nginx/certs -t'

      # docker gen image that auto-configures nginx reverse proxy for our jenkins container
      d.run 'docker-gen',
        daemonize: true,
        image: 'jwilder/docker-gen',
        cmd: '-notify-sighup nginx -watch -only-exposed /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf',
        args: '--volumes-from nginx -v /var/run/docker.sock:/tmp/docker.sock -v /opt/pipelet/config/nginx/conf:/etc/docker-gen/templates -t'

      d.run 'jenkins',
        daemonize: true,
        image: 'samsung_ag/jenkins-server',
        args: "-p 8080:8080 -p 50000:50000 --volumes-from jenkins-data -e VIRTUAL_HOST=#{hostname} -e VIRTUAL_PORT=8080 -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker -v /usr/lib/libdevmapper.so.1.02:/usr/lib/libdevmapper.so.1.02"
    end
  end
end