%w{cups cups-bsd printer-driver-hpcups hplip cups-pdf hplip-cups openprinting-ppds printer-driver-all foomatic-db-gutenprint libgd-tools fonts-droid gutenprint-locales liblcms2-utils lm-sensors snmp-mibs-downloader perl-doc libterm-readline-gnu-perl libterm-readline-perl-perl libpod-plainer-perl fonts-arphic-ukai fonts-arphic-uming fonts-unfonts-core gutenprint-doc hpijs-ppds hplip-doc cifs-utils openssl-blacklist}.each do |pkg|
  package pkg do
    action :install
  end
end

execute "Setup LaserJet" do
  command "lpadmin -p npi_office -v socket://192.168.50.85 -m drv:///hpcups.drv/hp-laserjet_p4015dn.ppd -L 'NPI Front Office LaserJet P4015' -E"
  action :run
end

execute "Set Default Printer" do
  command "lpadmin -d npi_office"
  action :run
end