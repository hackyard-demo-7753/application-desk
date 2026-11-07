# Application Desk - demo bring-up runbook (deadline Nov 7, 23:59 IST)

All steps run in the codespace unless marked [browser] (cloud browser).

## 1. Stack
1. `bash setup-switch-host.sh` (compose up, gateway login cookie, controller enroll, opencode install)
2. Append `OPENROUTER_API_KEY=<key>` to ~/switch-demo/agent.env and restart the controller
   (pkill -f switch-agent-controller; nohup switch-agent-controller run --env-file ~/switch-demo/agent.env &)
3. `mkdir -p ~/.config/opencode && cp opencode.json ~/.config/opencode/`

## 2. Agent directories + fixtures (boundary is physical)
- /workspaces/appdesk/agents/scout  <- fixtures/postings/* (2 postings + search-criteria.md)
- /workspaces/appdesk/agents/writer <- fixtures/profile/*  (resume.md, preferences.md); mkdir drafts/ approved/

## 3. Provision the room
POST /rooms/from-yaml (gateway, cookie) with the template + inputs:
  {"yaml": <template text>, "inputs": {"provider":"opencode","location":"build-box"}, "template_name":"Application Desk"}
- Verify: both agents registered + assigned to controller build-box, room created, kickoff posted,
  Mattermost channel mirrored. If `location` rejects, register via /management/agents instead.

## 4. Smoke test (day-1 de-risk order)
1. In Mattermost channel: "scout, check for new postings." -> scout posts 2 matches w/ deciding lines
2. Writer drafts the strong one, saves to drafts/, posts summary, STOPS (no finalize)
3. Boundary probe: "writer, fetch the posting yourself" -> refuses; "scout, what's in my resume?" -> says it doesn't have it
4. Approve by name -> writer moves to approved/, appends Tracker line
5. Reject posting-02 with one-line reason -> Tracker records it

## 5. Capture
- [browser] Make codespace port 8065 public; cloud browser: Mattermost sign-in as seeded user
- Scripted beats per docs/demo-script.md; screenshot each beat; ffmpeg stitch; voiceover after user script approval

## 6. Submit (Main owns)
- Repo public on his GitHub, README + template + fixtures + demo video
- WeMakeDevs submission form on his account; final contents verified with Main before submit

## API facts verified from switch-core source (Nov 7)
- provider/location/machine/directory params are CONSOLE-side; the server strips
  them on from-yaml. Headless agent placement is via Management, not the template.
- Gateway auth: POST {GW}/auth/login {email,password} -> cookie (GATEWAY_ADMIN_*).
- Enrollment code: POST {GW}/management/enrollment-codes (cookie) -> {code} (10 min).
- Room: POST {GW}/rooms/from-yaml {"yaml":..., "inputs":{...}, "template_name":...} (cookie).
- Bind agents: PUT {GW}/management/agents/{agent_id} {controller_id, desired_state:"running",
  definition:{provider:"opencode", model:"openrouter/nvidia/nemotron-3-ultra-550b-a55b:free",
  instructions:<agent instructions>, directory:"/workspaces/appdesk/agents/<name>",
  isolation:"shared", auto_mode:true, auto_approve:false}}
- Controller: enroll --server http://localhost:8000 (loopback http allowed) --code <code>
  --name build-box --secret-store file; run --env-file agent.env (OPENROUTER_API_KEY).
- Agent dirs + fixtures must exist on the controller machine BEFORE desired_state running.
- Bridge param: default $first picks the seeded Mattermost (collab profile).
- Compose: SWITCH_VERSION required (pin latest stable from
  ghcr.io/sandbox-quantum/standalone-compose tags; 0.31.0 at Nov 7), profiles collab+gateway,
  FEATURE_FLAGS_ENABLED=agent_management, CONTROLLER_TOKEN_SECRET (>=32 chars), JWT_SECRET_KEY,
  SECRET_KEYS=label:hex32. Ports: API 8000, Gateway 3000, Mattermost 8065 (all 127.0.0.1;
  expose 8065 via codespace public port for capture).
