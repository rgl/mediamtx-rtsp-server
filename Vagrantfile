VM_CPUS = 4
VM_MEMORY_MB = 4*1024

Vagrant.configure(2) do |config|
  config.vm.box = 'windows-2022-uefi-amd64'

  config.vm.provider 'libvirt' do |lv, config|
    lv.memory = VM_MEMORY_MB
    lv.cpus = VM_CPUS
    lv.cpu_mode = 'host-passthrough'
    lv.keymap = 'pt'
    lv.nested = true
    lv.disk_bus = 'scsi'
    lv.disk_device = 'sda'
    lv.disk_driver :discard => 'unmap', :cache => 'unsafe'
    # XXX virtiofs is not yet working.
    #     see https://gitlab.com/virtio-fs/virtiofsd/-/issues/57
    #     see https://github.com/vagrant-libvirt/vagrant-libvirt/discussions/1324
    # lv.memorybacking :source, :type => 'memfd'  # required for virtiofs.
    # lv.memorybacking :access, :mode => 'shared' # required for virtiofs.
    # config.vm.synced_folder '.', '/vagrant', type: 'virtiofs'
    config.vm.synced_folder '.', '/vagrant',
      type: 'smb',
      smb_username: ENV['VAGRANT_SMB_USERNAME'] || ENV['USER'],
      smb_password: ENV['VAGRANT_SMB_PASSWORD']
  end

  config.vm.provision "shell", path: "provision/ps.ps1", args: "provision/provision-base.ps1"
  config.vm.provision "shell", path: "provision/ps.ps1", args: "provision/provision-mediamtx.ps1"
end
