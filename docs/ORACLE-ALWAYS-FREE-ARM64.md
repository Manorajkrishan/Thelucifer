# Lucifer X — Oracle Cloud Always Free ARM64 staging

**STATUS: Repo configuration prepared only. No Oracle account, VM, paid resource,
database, or deployed backend has been created by these changes.**

> Important October 2026 free-tier update: Oracle currently lists **1,500
> OCPU-hours and 9,000 GB-hours per month** for Ampere A1. That equates to **2
> OCPUs / 12 GB RAM** on an Always Free tenancy — not the old 4 / 24 figure.
> Official: https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm

## Phase A — sign up and free-resource checks (account holder action)

1. Sign up at https://www.oracle.com/cloud/free/ . Oracle generally requires
   phone/card verification. A Free Trial is NOT a commitment to any paid upgrade.
   We do not have access to your OCI account in ChatGPT.
2. Choose the **home region** carefully: Always Free Compute is available only
   in that region. Pick one close to you with eligible A1 capacity.
3. From Oracle Cloud Console -> Compute -> Instances -> Create instance:
   - Name: `lucifer-x-staging-a1`
   - Shape: **VM.Standard.A1.Flex** (Ampere Arm / aarch64)
   - Allocate **2 OCPUs, 12 GB** RAM (or reduce these if other A1 VMs exist).
   - Image: Always Free eligible **Ubuntu 24.04 AArch64** (if offered).
   - Boot volume: default **50 GB**, counts toward 200 GB total free block
     volume quota. Don't add a paid backup/disk, load balancer, NAT gateway,
     additional paid public IP, or paid network component.
   - Network: a VCN/subnet with outbound internet for apt/container pulls.
     For first SSH access, if assigning a public IPv4, configure security-list
     or NSG inbound TCP/22 from **your CURRENT IP /32 ONLY**. Never 0.0.0.0/0.
     Do not open ports 80, 443, 8080, 5000, 8000, 5432.
   - Save your SSH **private key only on your computer**. Never commit or paste
     a key, password, card, cloud token, or console recovery code into chat.
4. Verify the instance is labelled **Always Free Eligible** and tenancy is
   Free Tier. Reject any paid plan, capacity upgrade, paid public service, or
   request to upgrade to Pay As You Go.
5. Check Billing and Cost Management -> Budgets. A budget/alert is **not a hard
   spending cap**, so stay within the fixed Always Free shape/volume limits.
   Oracle may reclaim idle Always Free instances; this staging environment
   must not hold irreplaceable data.

## Phase B — install Docker and join a private Tailscale network

SSH into the VM using Oracle's displayed IP and your own downloaded key.
Run these on **Ubuntu ARM64 on your OCI VM**, not your local Windows PowerShell:

```bash
uname -m  # must show aarch64
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 git curl openssl
sudo systemctl enable --now docker
docker --version
sudo docker compose version
```

For Tailscale, use the current instructions at
https://tailscale.com/docs/how-to/install/linux . Join *your* private tailnet
by running `sudo tailscale up` and following the sign-in URL shown on the VM.
Install Tailscale on the laptop/mobile you use to open Lucifer. Review tailnet
access policies: only your own trusted identity/devices should access this host.
**Never enable Tailscale Funnel** (Funnel makes the service internet-public).

If `docker-compose-v2` isn't available through your Ubuntu repositories,
follow Docker's official Ubuntu Compose-plugin install documentation at
https://docs.docker.com/engine/install/ubuntu/ rather than using a paid service.

## Phase C — secrets and checks (keep all data disposable)

```bash
git clone --single-branch --branch staging/milestone-2-private-stack-20261014 \
  https://github.com/Manorajkrishan/Thelucifer.git lucifer-x
cd lucifer-x
sudo bash infrastructure/oracle/prepare-secrets.sh
# Generates a fresh PostgreSQL username/password, 32-byte ML token, Laravel key,
# storing them only in /etc/lucifer-x/staging.env (root owner / chmod 0600).
sudo docker compose --env-file /etc/lucifer-x/staging.env \
  -f infrastructure/oracle/compose.yaml config --quiet
```

IMPORTANT: generating new staging secrets does **not** revoke any old passwords
or tokens leaked in Git history. Those previously used secrets MUST still be
rotated at the old systems, after auditing if they remain active.

Review image sources, dependencies and the result of the GitHub ARM64 CI gate
before running the stack:

```bash
sudo docker compose --env-file /etc/lucifer-x/staging.env \
  -f infrastructure/oracle/compose.yaml up -d --build
sudo docker compose --env-file /etc/lucifer-x/staging.env \
  -f infrastructure/oracle/compose.yaml ps
curl --fail http://127.0.0.1:8080/api/health
# It should report status=online, database=connected.
```

Provision a **disposable** account, with an email of your choice and a unique,
interactive strong password — it will NOT appear in shell history:

```bash
sudo docker compose --env-file /etc/lucifer-x/staging.env \
  -f infrastructure/oracle/compose.yaml exec api \
  php artisan sentinelai:create-admin --email=YOUR_TEST_EMAIL
```

Then allow only your private tailnet to view this loopback-only app:

```bash
sudo tailscale serve --bg http://127.0.0.1:8080
sudo tailscale serve status
```

Use the **https://…ts.net** URL reported by Tailscale Serve from an authenticated
tailnet device. Access from any other device or the open internet should fail.
If a non-tailnet browser can see it, disable it immediately with
`sudo tailscale serve off` and inspect network/firewall rules.
**Do not create public OCI ingress for this service**.

Tailscale Serve docs: https://tailscale.com/docs/reference/tailscale-cli/serve

## Architecture and explicit boundaries

```text
Laptop/phone with Tailscale → tailnet HTTPS / ACL
                                  |
                         Tailscale Serve
                                  |
                       127.0.0.1:8080 ONLY
                                  |
                          nginx + Vue login
                          /api/* → Laravel
                                     |
                            internal-only bridge
                                     |---------- PostgreSQL
                                     |---------- Flask ML
```

- PostgreSQL (15), Laravel API and Python inference are on internal Docker
  networking, with **no exposed or published host ports**.
- nginx is only bound to host `127.0.0.1:8080`. It must not bind `0.0.0.0`
  or use public OCI ingress. No publicly accessible API/backend.
- Vue uses `/api/` same-origin requests and Sanctum bearer tokens.
- Laravel registration is disabled; 5/min login throttling and 2/min attempted
  registration throttling; empty CORS allowed-origins. No direct ML browser calls.
- ML service is an inference-only ARM64 profile using the actual
  `services/threat_detector.py` and `security.py`. Models are NOT bundled.
  No model => safe HTTP 503, no fabricated detections. Unreviewed model loading,
  automatic mitigation, dataset downloads, document training, offensive modules,
  Neo4j, Redis and socket access are **not enabled** in this preview.
- Laravel `GET /api/ml/status` is authenticated and calls private Flask
  `/api/v1/status` using the shared server-side bearer token. It returns
  model availability, never a token or private address.
- Frontend token storage in localStorage and the absence of fine-grained
  Laravel admin RBAC are **remaining staging limitations**; use only a private,
  single-user disposable account, no actual customer/sensitive data.

## Testing / ongoing operations

- Native ARM64 GitHub Actions workflow: `.github/workflows/oracle-arm64.yml`.
  Includes native Docker builds, local bind inspection, API/Postgres health,
  login/authentication checks, and Laravel→Flask private token handshake.
- To stop: `sudo docker compose --env-file /etc/lucifer-x/staging.env -f
  infrastructure/oracle/compose.yaml stop`.
- To stop Tailscale publishing: `sudo tailscale serve off`.
- Never run `docker compose down -v` against the real staging database unless
  you intend to destroy all data.
- No deployment has been done by updating this branch. Don't merge until CI
  passes and stale leaked credentials on earlier systems are addressed.
- The separate Vercel synthetic preview stays disconnected from this private
  stack. **No direct browser bridge from public Vercel to private Tailscale**.
