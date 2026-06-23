from fastapi import APIRouter, BackgroundTasks, HTTPException
from app.models.vm import VMRequest, VMResponse
from app.services.provisioning import provision_vm

router = APIRouter(prefix="/vms", tags=["VMs"])

# Stockage en mémoire (à remplacer par PostgreSQL côté groupe)
vm_jobs: dict = {}

@router.post("/provision", response_model=VMResponse)
async def provision(request: VMRequest, background_tasks: BackgroundTasks):
    """Provisionne une ou plusieurs VMs pour un étudiant."""
    job_id = f"{request.student_name}-{request.course_type}"

    # Lancement en arrière-plan pour ne pas bloquer l'API
    background_tasks.add_task(
        _run_provisioning,
        job_id,
        request.course_type,
        request.student_name,
        request.vm_count,
        str(request.end_date),
        request.ssh_public_key
    )

    vm_jobs[job_id] = {"status": "provisioning"}

    return VMResponse(
        status="provisioning",
        vm_names=[],
        vm_ips=[],
        course_type=request.course_type,
        end_date=str(request.end_date),
        message=f"Provisioning démarré. Vérifiez /vms/status/{job_id}"
    )

@router.get("/status/{job_id}")
async def get_status(job_id: str):
    """Vérifie le statut d'un provisioning en cours."""
    if job_id not in vm_jobs:
        raise HTTPException(status_code=404, detail="Job introuvable")
    return vm_jobs[job_id]

@router.get("/templates")
async def list_templates():
    """Liste les templates de cours disponibles."""
    return {
        "templates": [
            {"id": "linux-admin",   "name": "Administration Linux",
             "flavor": "a1-ram2-disk20-perf1", "outils": ["nmap", "ufw", "fail2ban", "nginx"]},
            {"id": "dev-web",       "name": "Développement Web",
             "flavor": "a1-ram4-disk50-perf1", "outils": ["nodejs", "nginx", "docker"]},
            {"id": "data-science",  "name": "Data Science",
             "flavor": "a1-ram8-disk50-perf1", "outils": ["python3", "pandas", "jupyterlab"]},
            {"id": "cybersecurity", "name": "Cybersécurité / CTF",
             "flavor": "a1-ram4-disk50-perf1", "outils": ["nmap", "wireshark", "hydra", "trivy"]},
        ]
    }

async def _run_provisioning(job_id, course_type, student_name,
                             vm_count, end_date, ssh_public_key):
    """Tâche background : Terraform + Ansible."""
    result = provision_vm(course_type, student_name, vm_count, end_date, ssh_public_key)
    vm_jobs[job_id] = result
