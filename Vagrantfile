# vim:set ft=ruby:

Vagrant.configure(2) do |config|
  config.vm.box = "terrywang/archlinux"
  config.vm.box_url = 'http://cloud.terry.im/vagrant/archlinux-x86_64.box'
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provision "shell", :privileged => false, :inline => <<-SHELL
    git clone https://github.com/844196/pacbundle
    (cd pacbundle; sudo make install)
    /usr/local/bin/pacbundle install /vagrant/Pacmanfile
  SHELL
  config.vm.provision "shell", :privileged => false, :inline => <<-SHELL
    git clone https://github.com/844196/dotfiles
    dotfiles/bootstrap
    sudo chsh -s $(which zsh) $USER
  SHELL
  config.vm.provision "shell", :privileged => false, :inline => <<-SHELL
    sudo timedatectl set-timezone Asia/Tokyo
    printf '[mysqld_safe]\ntimezone = JST\n' > ~/.my.cnf
  SHELL
  config.vm.provision "shell", :privileged => false, :path => "setup_lamp.sh"
end
