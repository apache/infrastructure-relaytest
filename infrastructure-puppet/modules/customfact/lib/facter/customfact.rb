require 'ipaddr'
require 'open-uri'
require 'json'

Facter.add("asfosrelease") do
  setcode do
    Facter::Util::Resolution.exec("facter operatingsystemrelease | sed -e 's/[[:punct:]]//g' | awk '{print tolower($0)}'")
  end
end

Facter.add("asfosname") do
  setcode do
    Facter::Util::Resolution.exec("facter operatingsystem | sed -e 's/[[:punct:]]//g' | awk '{print tolower($0)}'")
  end
end

Facter.add("ipaddress_primary") do
  setcode do
    if Facter.value('ipaddress_eth0')
      Facter.value('ipaddress_eth0')
    elsif Facter.value('ipaddress_em0')
      Facter.value('ipaddress_em0')
    elsif Facter.value('ipaddress_eth1')
      Facter.value('ipaddress_eth1')
    elsif Facter.value('ipaddress_em1')
      Facter.value('ipaddress_em1')
    else
      Facter.value('ipaddress')
    end
  end
end

Facter.add("asfcolo") do
  setcode do
    hostname = Facter.value('hostname')
    if hostname.include? "ubuntu1464"
      "vagrant"
    else
      ipadd = Facter.value('ipaddress_primary')
      case ipadd
      when /^140.211.11.([0-9]+)$/
        "osuosl"
      when /^192.87.106.([0-9]+)$/
        "sara"
      when /^160.45.251.([0-9]+)$/
        "fub"
      when /^9.9.9.([0-9]+)$/
        "rackspace"
      when /^67.195.81.([0-9]+)$/
        "yahoo"
      when /^172\.31\.3[2-9]|4[0-7]\.\d+$/
        "amz-vpc-virginia-1b"
      when /^10.0.([0-9]+).([0-9]+)$/
        "amz-vpc-virginia-1d"
      when /^10.3.([0-9]+).([0-9]+)$/
        "amz-vpc-us-west"
      when /^10.2.([0-9]+).([0-9]+)$/
        "amz-vpc-eu-west"
      when /^10.30.([0-9]+).([0-9]+)$/
        "amz-vpc-eu-central"
      when /^162.209.6.([0-9]+)$/
        "rax-vpc-us-mid"
      when /^10.41.([0-9]+).([0-9]+)$/
        "phoenixnap-public"
      when /^10.40.([0-9]+).([0-9]+)$/
        "phoenixnap-private"
      when /^163.172.([0-9]+).([0-9]+)$/
        "iliad-paris"
      when /^195.154.([0-9]+).([0-9]+)$/
        "iliad-paris"
      when /^62.210.([0-9]+).([0-9]+)$/
        "iliad-paris"
      when /^10.10.([0-9]+).([0-9]+)$/
        "lw-us"
      when /^10.20.([0-9])+.([0-9]+)$/
        "lw-nl"
      else
        "default"
      end
    end
  end
end

Facter.add("external_ip") do
  setcode do
    external_ip_api_url = URI('http://ip-api.com/json/')
    # make the call to ip-api to get 'org' for external_ip_api_url
    response = open(external_ip_api_url).read
    json_response = JSON.parse(response)
    external_ip = json_response["query"]
  end
end

Facter.add("dd_autotag_colo") do
  setcode do
    # should get local external IP from ip-api.com, no need for fqdn
    external_ip_api_url = URI('http://ip-api.com/json/')
    # make the call to ip-api to get 'org' for external_ip_api_url
    response = open(external_ip_api_url).read
    json_response = JSON.parse(response)
    dc_loc = json_response["isp"].downcase
    dc_country = json_response["country"].downcase
    #itterate through json_response and assign yaml from ../data/colo dir
    case
      when dc_loc.include?('amazon')
        "aws"
      when dc_loc.include?('google')
        "google"
      when dc_loc.include?('hetzner')
        "hetzner"
      when dc_loc.include?('leaseweb')
        # split out hosts based on geolocation
        case
          when dc_country == "netherlands"
            "leaseweb_eu"
          when dc_country == "united states"
            "leaseweb_us"
          end
      when dc_loc.include?('microsoft_corporation')
        "azure"
      when dc_loc.include?('network_education_and_research_in_oregon_nero')
        "osu"
      when dc_loc.include?('online')
        "online.net"
      when dc_loc.include?('rackspace')
        "rackspace"
      when dc_loc.include?('secured servers')
        "pnap"
      when dc_loc.include?('yahoo')
        "yahoo"
      else
        dc_loc
    end
  end
end

Facter.add("noderole") do
  setcode do
    hostname = Facter.value('hostname')
    if hostname.include? "tlp-"  # include tlp boxes in US and EU
      "tlpserver"
    elsif hostname.include? "asf9" # include all asf9?? Oath/Y! Jenkins nodes
      "jenkins"
    elsif hostname.include? "penates" # old named nodes
      "jenkins"
    elsif hostname.include? "pietas"
      "jenkins"
    elsif hostname.include? "pomona"
      "jenkins"
    elsif hostname.include? "prosperina"
      "jenkins"
    elsif hostname.include? "priapus"
      "jenkins"
    elsif hostname.include? "jenkins-win" # include all Windows nodes
      "jenkins-win"
    elsif hostname.include?("jenkins-beam") || hostname.include?("beam-jenkins")
      "jenkins-external"
    elsif hostname.include?("jenkins-cassandra")
      "jenkins-external"
    elsif hostname =~ /openwhisk-vm\d-he-de/ # OpenWhisk Jenkins boxes
      "jenkins-external"
    else
      "default"
    end
  end
end

Facter.add("oem") do
  setcode do
    oem = Facter.value('bios_vendor')
    if oem =~ /dell/i
      "dell"
    end
  end
end

Facter.add("masklength") do
  setcode do
    netmask = Facter.value('netmask')
    IPAddr.new(netmask).to_i.to_s(2).count("1")
  end
end
