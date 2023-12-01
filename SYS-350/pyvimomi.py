import getpass
import json
import ssl
from os.path import realpath, dirname
from pyVim.connect import SmartConnect, Disconnect


def connect_to_vcenter(vcenter, username, password):
    context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    context.verify_mode = ssl.CERT_NONE
    try:
        si = SmartConnect(host=vcenter, user=username, pwd=password, sslContext=context)
        return si
    except Exception as e:
        print(f"Unable to connect to vCenter {e}")
        return None


def print_vm_info(vm):
    print("---")
    print(f"VM Name: {vm.name}")
    print(f"VM Power State: {vm.summary.runtime.powerState}")
    print(f"VM CPU number: {vm.summary.config.numCpu}")
    print(f"VM Memory Size (GB): {vm.summary.config.memorySizeMB / 1000}")
    print(f"VM IP Address: {vm.guest.ipAddress}")


if __name__ == "__main__":
    script_directory = dirname(realpath(__file__))
    passw = getpass.getpass()
    with open(f"{script_directory}/vars.json", "r") as v:
        user_vars = json.loads(v.read())
    vcenter_host = user_vars["vcenter"]
    username = user_vars["username"]
    service_instance = connect_to_vcenter(vcenter_host, username, passw)
    if service_instance:
        try:
            session = service_instance.content.sessionManager.currentSession
            vm_folders = service_instance.content.rootFolder.childEntity[0].hostFolder.childEntity[3]
            print(
                f"Session Info\nuser={session.userName}\nsourceip={session.ipAddress}\nvcenterip={vcenter_host}")
            user_search_key = input('Search Key for VMs')
            if user_search_key:
                vm_list = [
                    vm for vm in vm_folders.resourcePool.vm if user_search_key in vm.name]
            else:
                vm_list = [
                    vm for vm in vm_folders.resourcePool.vm]
            print("VM Key")
            for vm in vm_list:
                print_vm_info(vm)
        finally:
            Disconnect(service_instance)
    else:
        print("Unable to connect to vCenter")
