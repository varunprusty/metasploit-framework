#
# $Id$ ##

# ## This file is part of the Metasploit Framework and may be subject to
# redistribution and commercial restrictions. Please see the Metasploit
# Framework web site for more information on licensing and terms of use.
# http://metasploit.com/framework/ ##

require 'msf/core'
require 'rex'
require 'msf/core/post/windows/registry'

class Metasploit3 < Msf::Post

	include Msf::Post::Registry

	def initialize(info={})
		super( update_info( info,
				'Name'          => 'Check if VM',
				'Description'   => %q{ This module will check if target host is a virtual machine.},
				'License'       => MSF_LICENSE,
				'Author'        => [ 'Carlos Perez <carlos_perez[at]darkoperator.com>'],
				'Version'       => '$Revision$',
				'Platform'      => [ 'windows' ],
				'SessionTypes'  => [ 'meterpreter' ]
			))
	end

	# Method for detecting if it is a Hyper-V VM
	def hypervchk(session)
		begin
			vm = false
			key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft', KEY_READ)
			sfmsvals = key.enum_key
			if sfmsvals.include?("Hyper-V")
				print_status("This is a Hyper-V Virtual Machine")
				vm = true
			elsif sfmsvals.include?("VirtualMachine")
				print_status("This is a Hyper-V Virtual Machine")
				vm = true
			end
			key.close
		rescue
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("vmicheartbeat")
					print_status("This is a Hyper-V Virtual Machine")
					vm = true
				elsif srvvals.include?("vmicvss")
					print_status("This is a Hyper-V Virtual Machine")
					vm = true
				elsif srvvals.include?("vmicshutdown")
					print_status("This is a Hyper-V Virtual Machine")
					vm = true
				elsif srvvals.include?("vmicexchange")
					print_status("This is a Hyper-V Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		return vm
	end

	# Method for checking if it is a VMware VM
	def vmwarechk(session)
		vm = false
		begin
			key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
			srvvals = key.enum_key
			if srvvals.include?("vmdebug")
				print_status("This is a VMware Virtual Machine")
				vm = true
			elsif srvvals.include?("vmmouse")
				print_status("This is a VMware Virtual Machine")
				vm = true
			elsif srvvals.include?("VMTools")
				print_status("This is a VMware Virtual Machine")
				vm = true
			elsif srvvals.include?("VMMEMCTL")
				print_status("This is a VMware Virtual Machine")
				vm = true
			end
			key.close
		rescue
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0')
				if key.query_value('Identifier').data.downcase =~ /vmware/
					print_status("This is a VMware Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			vmwareprocs = [
				"vmwareuser.exe",
				"vmwaretray.exe"
			]
			vmwareprocs.each do |p|
				session.sys.process.get_processes().each do |x|
					if p == (x['name'].downcase)
						print_status("This is a VMware Virtual Machine") if not vm
						vm = true
					end
				end
			end
		end
		key.close
		return vm

	end

	# Method for checking if it is a Virtual PC VM
	def checkvrtlpc(session)
		vm = false
		vpcprocs = [
			"vmusrvc.exe",
			"vmsrvc.exe"
		]
		vpcprocs.each do |p|
			session.sys.process.get_processes().each do |x|
				if p == (x['name'].downcase)
					print_status("This is a VirtualPC Virtual Machine") if not vm
					vm = true
				end
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("vpcbus")
					print_status("This is a VirtualPC Virtual Machine")
					vm = true
				elsif srvvals.include?("vpc-s3")
					print_status("This is a VirtualPC Virtual Machine")
					vm = true
				elsif srvvals.include?("vpcuhub")
					print_status("This is a VirtualPC Virtual Machine")
					vm = true
				elsif srvvals.include?("msvmmouf")
					print_status("This is a VirtualPC Virtual Machine")
					vm = true
				end
				key.close
			rescue
			end
		end
		return vm
	end

	# Method for checking if it is a VirtualBox VM
	def vboxchk(session)
		vm = false
		vboxprocs = [
			"vboxservice.exe",
			"vboxtray.exe"
		]
		vboxprocs.each do |p|
			session.sys.process.get_processes().each do |x|
				if p == (x['name'].downcase)
					print_status("This is a Sun VirtualBox Virtual Machine") if not vm
					vm = true
				end
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\DSDT', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("VBOX__")
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\FADT', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("VBOX__")
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\RSDT', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("VBOX__")
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0')
				if key.query_value('Identifier').data.downcase =~ /vbox/
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\DESCRIPTION\System')
				if key.query_value('SystemBiosVersion').data.downcase =~ /vbox/
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("VBoxMouse")
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				elsif srvvals.include?("VBoxGuest")
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				elsif srvvals.include?("VBoxService")
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				elsif srvvals.include?("VBoxSF")
					print_status("This is a Sun VirtualBox Virtual Machine")
					vm = true
				end
				key.close
			rescue
			end
		end
		return vm
	end

	# Method for checking if it is a Xen VM
	def xenchk(session)
		vm = false
		xenprocs = [
			"xenservice.exe"
		]
		xenprocs.each do |p|
			session.sys.process.get_processes().each do |x|
				if p == (x['name'].downcase)
					print_status("This is a Xen Virtual Machine") if not vm
					vm = true
				end
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\DSDT', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("Xen")
					print_status("This is a Xen Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\FADT', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("Xen")
					print_status("This is a Xen Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'HARDWARE\ACPI\RSDT', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("Xen")
					print_status("This is a Xen Virtual Machine")
					vm = true
				end
			rescue
			end
		end
		if not vm
			begin
				key = session.sys.registry.open_key(HKEY_LOCAL_MACHINE, 'SYSTEM\ControlSet001\Services', KEY_READ)
				srvvals = key.enum_key
				if srvvals.include?("xenevtchn")
					print_status("This is a Xen Virtual Machine")
					vm = true
				elsif srvvals.include?("xennet")
					print_status("This is a Xen Virtual Machine")
					vm = true
				elsif srvvals.include?("xennet6")
					print_status("This is a Xen Virtual Machine")
					vm = true
				elsif srvvals.include?("xensvc")
					print_status("This is a Xen Virtual Machine")
					vm = true
				elsif srvvals.include?("xenvdb")
					print_status("This is a Xen Virtual Machine")
					vm = true
				end
				key.close
			rescue
			end
		end
		return vm
	end

	# run Method
	def run
		print_status("Checking if #{sysinfo['Computer']} is a Virtual Machine .....")
		found = hypervchk(session)
		found = vmwarechk(session) if not found
		found = checkvrtlpc(session) if not found
		found = vboxchk(session) if not found
		found = xenchk(session) if not found
		print_status("It appears to be physical host.") if not found
	end
end