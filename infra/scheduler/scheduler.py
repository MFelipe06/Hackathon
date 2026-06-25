#!/usr/bin/env python3
import openstack
import logging
from datetime import date

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)
log = logging.getLogger(__name__)

CLOUD_NAME = "infomaniak"

def main():
    log.info("=== Scheduler GIT Hackathon — démarrage ===")
    conn = openstack.connect(cloud=CLOUD_NAME)
    today = date.today()
    expired = []

    for vm in conn.compute.servers(details=True):
        metadata = vm.metadata or {}
        if metadata.get("managed_by") != "git-hackathon-terraform":
            continue
        end_date_str = metadata.get("end_date")
        if not end_date_str:
            log.warning(f"VM {vm.name} sans end_date — ignorée")
            continue
        try:
            end_date = date.fromisoformat(end_date_str)
        except ValueError:
            continue

        days_left = (end_date - today).days
        if days_left <= 0:
            log.info(f"VM expirée : {vm.name} (end_date={end_date_str})")
            expired.append(vm)
        elif days_left == 1:
            log.warning(f"⚠️  VM {vm.name} expire demain !")
        else:
            log.info(f"VM active : {vm.name} ({days_left} jour(s) restant(s))")

    if not expired:
        log.info("Aucune VM expirée — rien à faire")
        return

    for vm in expired:
        try:
            log.info(f"Destruction VM : {vm.name}")
            conn.compute.delete_server(vm.id, force=True)
            keypair_name = f"keypair-{vm.name}"
            try:
                conn.compute.delete_keypair(keypair_name)
                log.info(f"Keypair supprimée : {keypair_name}")
            except Exception:
                log.warning(f"Keypair {keypair_name} introuvable")
            log.info(f"✅ VM {vm.name} détruite")
        except Exception as e:
            log.error(f"❌ Erreur : {e}")

    log.info("=== Scheduler terminé ===")

if __name__ == "__main__":
    main()
