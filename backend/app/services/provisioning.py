import subprocess
import os
import time
import socket
from pathlib import Path

TERRAFORM_DIR = Path(__file__).parent.parent.parent.parent / "infra" / "terraform"
ANSIBLE_DIR   = Path(__file__).parent.parent.parent.parent / "infra" / "ansible"

def wait_for_ssh(ip: str, timeout: int = 300) -> bool:
    """Attend que le port SSH soit accessible sur la VM."""
    start = time.time()
    while time.time() - start < timeout:
        try:
            sock = socket.create_connection((ip, 22), timeout=5)
            sock.close()
            return True
        except (socket.timeout, ConnectionRefusedError, OSError):
            time.sleep(10)
    return False

def terraform_apply(course_type: str, student_name: str,
                    vm_count: int, end_date: str, ssh_public_key: str) -> dict:
    """Lance terraform apply et retourne les outputs."""
    env = {
        **os.environ,
        "TF_VAR_course_type":    course_type,
        "TF_VAR_student_name":   student_name,
        "TF_VAR_vm_count":       str(vm_count),
        "TF_VAR_end_date":       end_date,
        "TF_VAR_ssh_public_key": ssh_public_key,
    }

    # terraform init
    subprocess.run(
        ["terraform", "init", "-no-color"],
        cwd=TERRAFORM_DIR, env=env, check=True,
        capture_output=True
    )

    # terraform apply
    subprocess.run(
        ["terraform", "apply", "-auto-approve", "-no-color"],
        cwd=TERRAFORM_DIR, env=env, check=True,
        capture_output=True
    )

    # récupérer les outputs
    result = subprocess.run(
        ["terraform", "output", "-json"],
        cwd=TERRAFORM_DIR, env=env,
        capture_output=True, text=True, check=True
    )

    import json
    outputs = json.loads(result.stdout)
    return {
        "vm_ips":   outputs.get("vm_ips", {}).get("value", []),
        "vm_names": outputs.get("vm_names", {}).get("value", []),
    }

def ansible_provision(vm_ip: str, course_type: str) -> bool:
    """Lance le playbook Ansible sur la VM."""
    playbook = ANSIBLE_DIR / "playbooks" / f"{course_type}.yml"
    inventory = ANSIBLE_DIR / "inventory" / "hosts.yml"

    result = subprocess.run(
        [
            "ansible-playbook",
            "-i", str(inventory),
            str(playbook),
            "--extra-vars", f"vm_ip={vm_ip}",
            "-e", "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
        ],
        capture_output=True, text=True
    )
    return result.returncode == 0

def provision_vm(course_type: str, student_name: str,
                 vm_count: int, end_date: str, ssh_public_key: str) -> dict:
    """Orchestre Terraform + Ansible pour provisionner une VM."""
    try:
        # 1. Terraform
        tf_output = terraform_apply(
            course_type, student_name, vm_count, end_date, ssh_public_key
        )
        vm_ips   = tf_output["vm_ips"]
        vm_names = tf_output["vm_names"]

        # 2. Attendre SSH + lancer Ansible sur chaque VM
        for ip in vm_ips:
            if not wait_for_ssh(ip):
                return {
                    "status": "failed",
                    "message": f"SSH timeout sur {ip}",
                    "vm_ips": vm_ips,
                    "vm_names": vm_names
                }
            ansible_provision(ip, course_type)

        return {
            "status":  "ready",
            "vm_ips":  vm_ips,
            "vm_names": vm_names,
            "message": "VM(s) provisionnée(s) avec succès"
        }

    except subprocess.CalledProcessError as e:
        return {
            "status":  "failed",
            "message": f"Erreur Terraform : {e.stderr}",
            "vm_ips":  [],
            "vm_names": []
        }
