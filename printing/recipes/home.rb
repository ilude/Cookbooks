include_recipe "printing"

execute "Setup LaserJet" do
  command "lpadmin -p home -v socket://192.168.1.16 -m drv:///hpijs.drv/hp-officejet_6100_series-hpijs.ppd -L 'HP OfficeJet 6100' -E"
  action :run
end

execute "Set Default Printer" do
  command "lpadmin -d home"
  action :run
end