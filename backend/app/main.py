from fastapi import FastAPI
from app.routers import vms

app = FastAPI(
    title="GIT Hackathon — Provisioning API",
    description="Plateforme de provisioning de VMs pour le Geneva Institute of Technology",
    version="1.0.0"
)

app.include_router(vms.router)

@app.get("/")
def root():
    return {"status": "ok", "service": "GIT Provisioning API"}

@app.get("/health")
def health():
    return {"status": "healthy"}
