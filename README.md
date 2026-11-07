# Application Desk

A Switch room that turns internship postings into approved, ready-to-submit
applications. Built for the Flip the Switch hackathon (Track 02).

Two agents that cannot merge, one person in the middle:

- **scout** reads only public postings. It scores each one against public
  search criteria and posts the match, with the exact lines from the
  posting that decide the fit. It never sees the private profile.
- **writer** reads only the private profile. It never goes to the web; it
  drafts from what the scout posts in the room. Nothing it writes leaves
  `drafts/` without explicit approval.
- **you** hold the exclusive `approver` role. No application is finalized
  without your named approval in the room, and every decision lands in the
  room's permanent Tracker doc.

## Why Switch is load-bearing here

Remove Switch and the workflow collapses: the scout cannot hand a match to
the writer with context (they run with separate data on purpose, and the
room is the only channel between them), the approval has nowhere binding
to live (it would be a chat message an agent can ignore), and the Tracker
is not a shared permanent artifact. The room instructions, the exclusive
approver role, and the room doc are what keep the boundary and the gate
honest. Switch is the workflow, not a notification layer.

## Run it

You need Switch Console with a coding agent signed in (Claude Code, Codex,
or OpenCode all work).

1. Open `application-desk.template.yaml` from the Console's Templates page
   and run the form. Defaults put both agents on this machine, each with
   its own working directory.
2. Copy the fixtures into place:
   - `fixtures/postings/*` into the **scout**'s working directory
   - `fixtures/profile/*` into the **writer**'s working directory
   (The Console shows each agent's directory on its card.)
3. In the room, say: `scout, check for new postings.`
4. The scout posts its matches. The writer drafts the strong one and
   stops. Approve it by name - or reject it - and watch the Tracker.

The kickoff message has both agents state their own limits first, so the
first thing in the room is what each agent will and will not do.

## Demo data, honestly labeled

The committed postings and profile are **synthetic fixtures** (fictional
companies, fictional candidate) so anyone can reproduce the demo without
anyone's real data. They are labeled as saved data in every file, and the
scout says so when it uses them. In real use, a watcher saves genuine
public postings into the scout's folder and the real profile stays on the
owner's machine - it is never committed here.

## The boundary, mechanically

The scout's working directory contains only postings and public criteria;
the writer's contains only the profile. Each agent's tools reach its own
directory, so the writer cannot read a posting file and the scout cannot
read the resume. Ask the writer to fetch a posting itself and it refuses -
that refusal is part of the demo video.

## Reproduce from scratch

Delete the room and both agents, run the template again from this file,
copy the fixtures, and say `scout, check for new postings.` The whole
setup is this one YAML file plus the fixtures folder.

## Submission

Demo video: `docs/demo-script.md` (script reviewed before recording).
Room template: `application-desk.template.yaml`. This README points at
both rather than explaining them.
