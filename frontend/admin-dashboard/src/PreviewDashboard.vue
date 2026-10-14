<script setup>
import { ref, computed } from 'vue'

// Deliberately synthetic telemetry. This preview has no network clients,
// authentication endpoints, real sensors, or defensive action capabilities.
const records = Object.freeze([
  { id: 'LX-1001', type: 'Unusual sign-in', category: 'Identity', severity: 8, status: 'Investigating', source: '192.0.2.41', asset: 'Workstation-07', time: '09:42', detail: 'Five unsuccessful sign-in attempts followed by a successful sign-in from a test network.' },
  { id: 'LX-1002', type: 'Suspicious PowerShell', category: 'Endpoint', severity: 9, status: 'Open', source: '198.51.100.24', asset: 'Demo-Laptop-02', time: '09:28', detail: 'Command activity was flagged by a synthetic behavioural rule in the demo feed.' },
  { id: 'LX-1003', type: 'DNS anomaly', category: 'Network', severity: 6, status: 'Investigating', source: '203.0.113.8', asset: 'DNS-Gateway', time: '08:54', detail: 'Illustrative DNS request volume exceeded a predetermined example threshold.' },
  { id: 'LX-1004', type: 'Phishing indicator', category: 'Email', severity: 7, status: 'Open', source: '192.0.2.92', asset: 'Mail-Sandbox', time: '08:30', detail: 'Example mail event contains a synthetic suspicious-link indicator.' },
  { id: 'LX-1005', type: 'Port scan pattern', category: 'Network', severity: 5, status: 'Resolved', source: '198.51.100.12', asset: 'Firewall-Demo', time: '07:51', detail: 'Sample network activity suggests repeated connection attempts across test ports.' },
  { id: 'LX-1006', type: 'Configuration drift', category: 'Cloud', severity: 4, status: 'Resolved', source: '203.0.113.16', asset: 'Cloud-Demo', time: '07:12', detail: 'An example configuration was compared with a known-good baseline.' }
])
const active = ref('Overview')
const search = ref('')
const severityFilter = ref('All')
const selected = ref(null)
const navigation = ['Overview', 'Threat feed', 'Incidents', 'Platform status']
const incidents = Object.freeze([
  { id: 'INC-042', title: 'Unusual access sequence', priority: 'High', owner: 'Unassigned', state: 'Triage', linked: 'LX-1001' },
  { id: 'INC-043', title: 'Endpoint execution alert', priority: 'Critical', owner: 'Unassigned', state: 'Open', linked: 'LX-1002' },
  { id: 'INC-044', title: 'DNS traffic variance', priority: 'Medium', owner: 'Unassigned', state: 'Monitoring', linked: 'LX-1003' }
])
const filtered = computed(() => records.filter(r => {
  const term = search.value.trim().toLowerCase()
  return (severityFilter.value === 'All' || (severityFilter.value === 'High' ? r.severity >= 8 : r.severity < 8)) &&
    (!term || [r.id, r.type, r.category, r.source, r.asset].some(v => v.toLowerCase().includes(term)))
}))
const openCount = records.filter(x => x.status === 'Open').length
const investigatingCount = records.filter(x => x.status === 'Investigating').length
function badgeStyle(severity) {
  return severity >= 8 ? 'critical' : severity >= 6 ? 'moderate' : 'low'
}
function pickRecord(row) {
  selected.value = row
}
</script>

<template>
  <div class="shell">
    <aside class="sidebar">
      <div class="brand">
        <div class="brand-icon">L<span>X</span></div>
        <div><div class="brand-title">LUCIFER <em>X</em></div><div class="brand-sub">CYBER DEFENSE CONSOLE</div></div>
      </div>
      <div class="workspace"><span class="workspace-dot"></span> Private preview <span class="workspace-caret">●</span></div>
      <div class="nav-label">WORKSPACE</div>
      <nav aria-label="Preview sections" class="nav-list">
        <button v-for="(item, index) in navigation" :key="item" :class="{ current: active === item }" @click="active = item; selected = null">
          <span class="nav-symbol">{{ ['◫','◈','▤','⌁'][index] }}</span> {{ item }}
          <span v-if="item === 'Threat feed'" class="nav-count">06</span>
        </button>
      </nav>
      <div class="sidebar-bottom">
        <div class="sidebar-status"><span class="status-light"></span> PREVIEW ENVIRONMENT</div>
        <p>UI demonstration only. No live telemetry, AI inference, or response commands are running.</p>
        <div class="branch">GitHub: preview/lucifer-x-…</div>
      </div>
    </aside>

    <div class="main-region">
      <header class="topbar">
        <div class="breadcrumb">Lucifer X <span>/</span> {{ active }}</div>
        <div class="top-right"><span class="not-live"><span>●</span> NO LIVE DATA</span><span class="profile">DEMO</span></div>
      </header>

      <main class="content">
        <div class="notice"><strong>ISOLATED DEMONSTRATION</strong><span>All events, identities and IP addresses are synthetic. No live services or credentials are connected.</span></div>

        <template v-if="active === 'Overview'">
          <div class="eyebrow">SECURITY OPERATIONS / DEMO WORKSPACE</div>
          <div class="heading"><div><h1>Security overview</h1><p>See how the analyst experience will look with a simulated event stream.</p></div><span class="date-pill">● SAMPLE DATASET · 6 EVENTS</span></div>
          <div class="metrics">
            <div class="metric"><div class="metric-label">TOTAL OBSERVATIONS <span>↗</span></div><div class="metric-value">06</div><p>In the synthetic event feed</p><div class="metric-mark">▅▅▇▇▆▇▇</div></div>
            <div class="metric"><div class="metric-label">OPEN ALERTS <span>◉</span></div><div class="metric-value amber">{{ openCount.toString().padStart(2,'0') }}</div><p>Awaiting analyst triage</p><div class="metric-mark orange">▇▆▇▆▅▆▇</div></div>
            <div class="metric"><div class="metric-label">UNDER REVIEW <span>◇</span></div><div class="metric-value blue">{{ investigatingCount.toString().padStart(2,'0') }}</div><p>Example investigations</p><div class="metric-mark cyan">▅▆▆▇▆▅▆</div></div>
            <div class="metric"><div class="metric-label">MODEL STATUS <span>◇</span></div><div class="metric-value muted" style="font-size:23px;margin-top:12px">NOT ACTIVE</div><p>No trained model deployed</p><div class="status-tiny">Safe by default · No predictions</div></div>
          </div>

          <div class="two-columns">
            <section class="panel panel-wide">
              <div class="panel-heading"><div><h2>Threat activity</h2><p>Illustrative event distribution by severity</p></div><div class="pill">Last six sample events</div></div>
              <div class="graph-area">
                <div class="graph-bars"><div class="graph-label">Critical <strong>2</strong></div><div class="graph-track"><div class="graph-fill redfill w33"></div></div></div>
                <div class="graph-bars"><div class="graph-label">Elevated <strong>2</strong></div><div class="graph-track"><div class="graph-fill amberfill w33"></div></div></div>
                <div class="graph-bars"><div class="graph-label">Low <strong>2</strong></div><div class="graph-track"><div class="graph-fill greenfill w33"></div></div></div>
              </div>
              <p class="graph-footer">Static visualization of documentation-only records. Not actual threat-detection performance.</p>
            </section>
            <section class="panel service-panel">
              <div class="panel-heading"><h2>Services & safety</h2><span class="light-dot"></span></div>
              <div class="service-line"><div><strong>Dashboard UI</strong><small>Read-only illustration</small></div><span class="service-ready">PREVIEW</span></div>
              <div class="service-line"><div><strong>ML inference</strong><small>Intentionally disabled</small></div><span class="service-off">OFFLINE</span></div>
              <div class="service-line"><div><strong>Response execution</strong><small>Not permitted</small></div><span class="service-off">DISABLED</span></div>
              <div class="service-line"><div><strong>Data sources</strong><small>Static documentation samples</small></div><span class="service-ready">SYNTHETIC</span></div>
            </section>
          </div>
          <section class="panel table-panel">
            <div class="panel-heading"><div><h2>Recent security events</h2><p>Click a sample event to inspect its explanation</p></div><button class="text-action" @click="active='Threat feed'">View all events →</button></div>
            <div class="table-wrap"><table><thead><tr><th>EVENT ID</th><th>DETECTION</th><th>SEVERITY</th><th>STATUS</th><th>TIME</th></tr></thead><tbody>
              <tr v-for="r in records.slice(0,4)" :key="r.id" @click="pickRecord(r)" tabindex="0" @keydown.enter="pickRecord(r)"><td class="mono">{{ r.id }}</td><td><div class="det-type">{{ r.type }}</div><div class="cell-sub">{{ r.asset }}</div></td><td><span class="sev" :class="badgeStyle(r.severity)">{{ r.severity }}/10</span></td><td><span class="state">{{ r.status }}</span></td><td class="mono">{{ r.time }}</td></tr>
            </tbody></table></div>
          </section>
        </template>

        <template v-else-if="active === 'Threat feed'">
          <div class="eyebrow">DETECTIONS / SAMPLE EVENTS</div><div class="heading"><div><h1>Threat intelligence feed</h1><p>Explore synthetic alerts without connecting any real infrastructure.</p></div><span class="date-pill">READ ONLY</span></div>
          <div class="filters"><input aria-label="Search sample events" v-model="search" placeholder="Search event, host, IP…" /><select aria-label="Filter severity" v-model="severityFilter"><option>All</option><option>High</option><option>Other</option></select></div>
          <section class="panel table-panel"><div class="table-wrap"><table><thead><tr><th>EVENT ID</th><th>OBSERVATION</th><th>ORIGIN</th><th>SEVERITY</th><th>STATUS</th></tr></thead><tbody><tr v-for="r in filtered" :key="r.id" @click="pickRecord(r)" tabindex="0" @keydown.enter="pickRecord(r)"><td class="mono">{{ r.id }}</td><td><div class="det-type">{{ r.type }}</div><div class="cell-sub">{{ r.category }}</div></td><td class="mono">{{ r.source }}</td><td><span class="sev" :class="badgeStyle(r.severity)">{{ r.severity }}/10</span></td><td><span class="state">{{ r.status }}</span></td></tr></tbody></table></div><p v-if="filtered.length===0" class="empty">No synthetic events match your filter.</p></section>
        </template>

        <template v-else-if="active === 'Incidents'">
          <div class="eyebrow">TRIAGE / SAMPLE CASES</div><div class="heading"><div><h1>Incident queue</h1><p>Example workflows for human-led analysis. No response actions are executable.</p></div><span class="date-pill">REVIEW ONLY</span></div>
          <div class="case-grid"><article class="case" v-for="c in incidents" :key="c.id"><div class="case-top"><span class="mono">{{ c.id }}</span><span class="sev" :class="c.priority==='Critical'?'critical':c.priority==='High'?'moderate':'low'">{{ c.priority }}</span></div><h3>{{ c.title }}</h3><p>Linked observation: {{ c.linked }}</p><div class="case-bottom"><span>{{ c.state }}</span><span>Assigned: {{ c.owner }}</span></div></article></div>
        </template>

        <template v-else>
          <div class="eyebrow">PLATFORM / RELEASE READINESS</div><div class="heading"><div><h1>Deployment readiness</h1><p>Security controls and dependencies still needed for a live, connected platform.</p></div></div>
          <section class="panel check-panel"><div class="service-line"><div><strong>Protected analyst preview</strong><small>Host-level Vercel Authentication required</small></div><span class="service-ready">REQUIRED</span></div><div class="service-line"><div><strong>Backend and database</strong><small>Not deployed to public hosting</small></div><span class="service-off">NOT CONNECTED</span></div><div class="service-line"><div><strong>Detection models</strong><small>Trusted model version + validation needed</small></div><span class="service-off">NOT CONNECTED</span></div><div class="service-line"><div><strong>Credential rotation</strong><small>Previous repository history needs review</small></div><span class="service-off">PENDING</span></div><div class="service-line"><div><strong>Response automation</strong><small>Requires approval/audit design</small></div><span class="service-off">DISABLED</span></div></section>
        </template>
      </main>
      <footer>Lucifer X · Isolated frontend preview · No real-world detection or response capability</footer>
    </div>
    <div v-if="selected" class="modal-backdrop" @click.self="selected=null"><section class="inspector" role="dialog" aria-modal="true" aria-label="Sample event details"><button class="close" aria-label="Close details" @click="selected=null">×</button><span class="eyebrow">SAMPLE EVENT / {{ selected.id }}</span><h2>{{ selected.type }}</h2><p class="inspector-note">Synthetic security telemetry. This observation was not generated by an AI model.</p><div class="inspector-row"><span>Severity</span><strong>{{ selected.severity }}/10</strong></div><div class="inspector-row"><span>Origin</span><strong>{{ selected.source }}</strong></div><div class="inspector-row"><span>Asset</span><strong>{{ selected.asset }}</strong></div><div class="inspector-row"><span>Status</span><strong>{{ selected.status }}</strong></div><h3>Evidence summary</h3><p>{{ selected.detail }}</p><div class="blocked">Response actions are disabled in this preview.</div></section></div>
  </div>
</template>

<style scoped>
:global(body){margin:0;background:#080e1b;color:#e5edf8;font-family:Inter,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}
:global(*){box-sizing:border-box}
button,input,select{font:inherit}
button{cursor:pointer}
.shell{display:flex;min-height:100vh;background:#0c1220}
.sidebar{width:264px;min-width:264px;background:#090f1c;border-right:1px solid #243145;display:flex;flex-direction:column;position:sticky;top:0;height:100vh}
.brand{display:flex;align-items:center;gap:12px;padding:30px 22px 32px}
.brand-icon{height:46px;width:46px;display:grid;place-items:center;background:linear-gradient(135deg,#0e5a69,#063449);color:#7affd2;font-size:19px;font-weight:900;border:1px solid #1b9c9d;border-radius:13px}
.brand-icon span{color:#fff}
.brand-title{font-size:18px;letter-spacing:1.7px;font-weight:850;color:white}.brand-title em{font-style:normal;color:#61ecc8}
.brand-sub{font-size:9px;letter-spacing:1.7px;color:#8398ad;margin-top:3px}
.workspace{display:flex;align-items:center;gap:10px;margin:0 16px 31px;padding:12px 14px;border:1px solid #25354d;border-radius:10px;background:#131e30;color:#c2d4e7;font-size:13px;font-weight:600}
.workspace-dot,.status-light,.light-dot{height:8px;width:8px;border-radius:100%;background:#53e0b4;display:inline-block;box-shadow:0 0 14px #40d4a944}
.workspace-caret{margin-left:auto;font-size:8px;color:#4bbd98}
.nav-label{color:#5f7693;font-size:10px;font-weight:750;letter-spacing:1.8px;padding:0 26px 12px}
.nav-list{display:flex;flex-direction:column;gap:6px;margin:0 12px}.nav-list button{width:100%;border:0;background:transparent;color:#9cb0c8;text-align:left;padding:13px 16px;border-radius:9px;font-size:13px;font-weight:600}.nav-list button:hover{background:#17263c;color:white}.nav-list button.current{color:#83ffe1;background:#103639;border:1px solid #1c6c69}.nav-symbol{display:inline-block;width:24px;font-size:18px}.nav-count{float:right;background:#1b3746;padding:1px 7px;border-radius:6px;font-size:11px}
.sidebar-bottom{margin-top:auto;padding:20px;border-top:1px solid #202d40}.sidebar-status{display:flex;align-items:center;gap:8px;color:#81efcf;font-weight:700;font-size:10px;letter-spacing:1px}.sidebar-bottom p{font-size:12px;line-height:1.7;color:#8295ad}.branch{border-top:1px solid #202b3e;padding-top:14px;color:#6b819b;font-size:11px}
.main-region{flex:1;min-width:0;display:flex;flex-direction:column}.topbar{height:77px;display:flex;align-items:center;justify-content:space-between;padding:0 38px;border-bottom:1px solid #223047;background:#101a2b}.breadcrumb{font-size:14px;font-weight:700;color:#bdcadb}.breadcrumb span{margin:0 13px;color:#4c607d}.top-right{display:flex;align-items:center;gap:20px}.not-live{font-size:10px;letter-spacing:1px;color:#f9c17d;font-weight:800}.not-live span{font-size:14px}.profile{background:#23344c;border:1px solid #3f5572;color:#afc9e1;border-radius:50%;height:37px;width:37px;display:grid;place-items:center;font-size:9px;font-weight:800}
.content{max-width:1450px;width:100%;padding:34px 38px 54px;margin:auto;flex:1}.notice{display:flex;gap:14px;align-items:center;background:#122a35;border:1px solid #26706b;color:#b4eade;padding:14px 18px;border-radius:10px;font-size:12px;margin-bottom:32px}.notice strong{letter-spacing:1.1px;color:#79f3d3;font-size:10px;white-space:nowrap}.eyebrow{color:#53dec2;font-size:10px;letter-spacing:2px;font-weight:800;margin-bottom:12px}.heading{display:flex;justify-content:space-between;gap:20px;align-items:center;margin-bottom:28px}.heading h1{font-size:31px;letter-spacing:-.8px;color:#f5f9ff;margin:0 0 9px;font-weight:750}.heading p{color:#92a7c0;margin:0;font-size:13px}.date-pill,.pill{font-size:10px;letter-spacing:1.2px;color:#9dbdd0;border:1px solid #30445a;background:#152438;border-radius:6px;padding:10px 13px;white-space:nowrap;font-weight:800}
.metrics{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:16px;margin-bottom:22px}.metric{position:relative;overflow:hidden;border:1px solid #273a52;background:linear-gradient(160deg,#19293e,#132034);border-radius:12px;padding:21px;min-height:175px}.metric-label{font-size:10px;color:#a1b1c7;font-weight:800;letter-spacing:1.2px;display:flex;justify-content:space-between}.metric-label span{color:#7190a9;font-size:16px}.metric-value{font-size:43px;font-weight:760;color:#f8fbff;letter-spacing:-1px;margin-top:18px}.metric-value.amber{color:#f8bd79}.metric-value.blue{color:#73c2ff}.metric-value.muted{color:#ffcc96}.metric p{font-size:11px;color:#8397ad;margin:3px 0}.metric-mark{position:absolute;right:16px;bottom:17px;color:#51ddbb44;letter-spacing:-3px;font-size:23px}.metric-mark.orange{color:#e7ab5740}.metric-mark.cyan{color:#66a8e940}.status-tiny{color:#78c9ba;font-size:10px;margin-top:12px}
.two-columns{display:grid;grid-template-columns:minmax(0,1.55fr) minmax(250px,1fr);gap:20px;margin-bottom:22px}.panel{background:#142136;border:1px solid #2a3a51;border-radius:13px;overflow:hidden}.panel-heading{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;padding:24px 24px 17px}.panel-heading h2{margin:0;font-size:17px;font-weight:750;color:#ecf4ff}.panel-heading p{color:#8095af;font-size:12px;margin:8px 0 0}.graph-area{padding:16px 26px}.graph-bars{display:grid;grid-template-columns:100px 1fr;align-items:center;gap:15px;margin:24px 0}.graph-label{display:flex;justify-content:space-between;font-size:12px;color:#b6c6d9}.graph-label strong{color:#f4f8ff}.graph-track{height:13px;background:#0b1525;border-radius:50px;overflow:hidden}.graph-fill{height:100%;border-radius:50px}.w33{width:33.33%}.redfill{background:#ec7680}.amberfill{background:#f3b35a}.greenfill{background:#43cbab}.graph-footer{margin:3px 26px 23px;font-size:11px;color:#738aa5}.service-panel{padding-bottom:6px}.service-line{margin:0 21px;padding:17px 0;display:flex;justify-content:space-between;align-items:center;gap:8px;border-top:1px solid #26374d}.service-line strong{color:#dce7f3;font-size:12px;display:block}.service-line small{color:#7189a4;font-size:11px;margin-top:5px;display:block}.service-ready,.service-off{font-size:9px;border-radius:6px;letter-spacing:.8px;font-weight:900;padding:7px 8px;white-space:nowrap}.service-ready{background:#113c37;color:#80ebbd}.service-off{background:#3d2f31;color:#f5bd9d}
.table-panel .panel-heading{padding-bottom:24px}.text-action{border:0;background:none;color:#74dec7;font-size:12px;font-weight:700}.table-wrap{overflow-x:auto}table{width:100%;border-collapse:collapse;text-align:left}th{font-size:10px;letter-spacing:1.1px;color:#7a93ad;background:#101c30;padding:13px 22px}td{padding:16px 22px;border-top:1px solid #243449;color:#a9bdd2;font-size:12px}tbody tr{cursor:pointer}tbody tr:hover{background:#1b2c43}tbody tr:focus-visible{outline:2px solid #66e4c6}.mono{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;color:#c7def2}.det-type{font-size:13px;color:#e6f1fc;font-weight:650}.cell-sub{font-size:11px;margin-top:5px;color:#7f97ad}.sev{padding:6px 9px;border-radius:6px;font-size:10px;font-weight:750;white-space:nowrap}.sev.critical{background:#4b2734;color:#ffa3a6}.sev.moderate{background:#4a3828;color:#ffcb83}.sev.low{background:#203f39;color:#8de6b8}.state{font-size:11px;font-weight:700;color:#bdcde0}.filters{display:flex;gap:12px;margin-bottom:20px}.filters input,.filters select{padding:14px 16px;border-radius:9px;background:#142339;border:1px solid #35475e;color:#d5e7f6}.filters input{flex:1}.filters select{min-width:140px}.empty{padding:30px;color:#93a8c3}.case-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px}.case{background:#15253b;border:1px solid #2d4157;border-radius:12px;padding:23px}.case-top,.case-bottom{display:flex;justify-content:space-between;gap:8px;align-items:center}.case h3{font-size:17px;color:#eef7ff;margin:26px 0 10px}.case p{font-size:12px;color:#8ba5bb}.case-bottom{border-top:1px solid #31455d;padding-top:17px;margin-top:25px;font-size:11px;color:#7d98b1}.check-panel{padding:14px 10px}footer{padding:18px 38px;border-top:1px solid #1c2a3d;color:#667d96;font-size:11px}
.modal-backdrop{position:fixed;inset:0;background:#030810bb;display:flex;justify-content:flex-end;z-index:20}.inspector{width:min(420px,100vw);height:100vh;overflow:auto;background:#132136;border-left:1px solid #33536a;padding:38px;color:#dde9f7;position:relative}.close{position:absolute;right:25px;top:20px;border:0;background:none;color:#aac0d5;font-size:29px}.inspector h2{font-size:26px;margin:20px 0 10px}.inspector-note{background:#254136;border:1px solid #3b6758;padding:15px;border-radius:7px;color:#afe0c8;font-size:12px;line-height:1.7}.inspector-row{display:flex;justify-content:space-between;padding:17px 0;border-bottom:1px solid #34445a;color:#93a9be;font-size:13px}.inspector-row strong{color:#e2edf9}.inspector h3{margin-top:35px;font-size:15px}.inspector>p{font-size:13px;line-height:1.8;color:#afc2d6}.blocked{background:#442e33;color:#ffb6ae;border-radius:8px;font-size:12px;padding:16px;margin-top:28px}
@media(max-width:1100px){.metrics{grid-template-columns:repeat(2,1fr)}.two-columns,.case-grid{grid-template-columns:1fr}.sidebar{width:216px;min-width:216px}.content{padding:25px}}
@media(max-width:730px){.shell{display:block}.sidebar{position:static;height:auto;width:100%;min-width:0}.brand{padding:15px}.workspace,.nav-label,.sidebar-bottom{display:none}.nav-list{flex-direction:row;overflow:auto;padding:6px 8px 13px}.nav-list button{white-space:nowrap;width:auto}.main-region{width:100%}.topbar{height:60px;padding:0 16px}.content{padding:20px 15px}.heading{align-items:start;flex-direction:column}.heading h1{font-size:25px}.metrics{grid-template-columns:repeat(2,minmax(0,1fr));gap:9px}.metric{padding:13px;min-height:154px}.metric-value{font-size:31px}.metric-label{font-size:9px}.date-pill{white-space:normal}.notice{display:block;line-height:1.8}.notice strong{display:block}.filters{flex-direction:column}footer{padding:18px}.nav-symbol{width:16px}}
</style>
