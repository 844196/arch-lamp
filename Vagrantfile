# vim:set ft=ruby:

Vagrant.configure(2) do |config|
  config.vm.box = "terrywang/archlinux"
  config.vm.box_url = 'http://cloud.terry.im/vagrant/archlinux-x86_64.box'
  config.vm.network "private_network", ip: "192.168.33.10"

  # set machine timezone
  config.vm.provision "shell", :privileged => true, :inline => <<-SHELL
    timedatectl set-timezone Asia/Tokyo
    printf '[mysqld_safe]\ntimezone = JST\n' >> /etc/my.cnf
  SHELL

  # install Pacbundle
  config.vm.provision "shell", :privileged => false, :inline => <<-SHELL
    git clone https://github.com/844196/pacbundle
    (cd pacbundle; sudo make install)
  SHELL

  # setup my toolkit
  # config.vm.provision "shell", :privileged => false, :inline => <<-SHELL
  #   git clone https://github.com/844196/dotfiles
  #   pacbundle install dotfiles/etc/Pacmanfile
  #   dotfiles/bootstrap
  # SHELL

  # setup LAMP
  config.vm.provision "shell", :privileged => true, :inline => <<-SHELL
    pacbundle install /vagrant/LAMP_Package
    /vagrant/LAMP_Setup.sh
  SHELL

  # # change shell
  # config.vm.provision "shell", :privileged => true, :inline => <<-SHELL
  #   chsh -s $(which zsh) vagrant
  # SHELL
end
