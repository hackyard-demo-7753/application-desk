# Application Desk

A Switch room that turns internship postings into approved, ready-to-submit
applications. Built for the Flip the Switch hackathon (Track 02).

Two agents with separate jobs and separate data, one person in the middle:

- **scout** reads only public postings. It scores each one against public
  search criteria and posts the match, with the exact lines from the
  posting that decide the fit. Its instructions confine it to postings -
  the private profile is not in its directory.
- **writer** reads the private profile and what the scout posts in the
  room - never the web. It drafts, saves to `drafts/`, and stops.
  Nothing it writes leaves `drafts/` without explicit approval.
- **you** are the only approver. By room instruction, no application is
  finalized without your named approval in the room, and every decision
  lands in the room's tracker file.

## Why Switch is load-bearing here

The room is the whole product. It is the shared channel where the scout
hands a match to the writer with full context (they keep separate data on
purpose - in the demo the writer refuses to fetch a posting from the web
itself and asks the scout for it through the room instead), the place the
human approval gate lives, and the shared record the tracker is written
from. The room template and the agents' instructions carry the workflow;
Switch is what puts all of it in one place.

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
   stops. Approve it by name - or reject it - and watch the tracker.

The kickoff message has both agents state their own limits first, so the
first thing in the room is what each agent will and will not do.

## Demo data, honestly labeled

The committed postings and profile are **synthetic fixtures** (fictional
companies, fictional candidate) so anyone can reproduce the demo without
anyone's real data. They are labeled as saved data in every file, and the
scout says so when it uses them. In real use, a watcher saves genuine
public postings into the scout's folder and the real profile stays on the
owner's machine - it is never committed here.

## The boundary, honestly

Each agent works in its own directory - the scout's holds only postings
and public criteria, the writer's holds only the profile - and each
agent's instructions confine it to its own data. This is
**instruction-based separation, demonstrated in the demo - not a hard
access-control boundary**. Ask the writer to fetch a posting itself and
it refuses, then asks the scout for it through the room; ask the scout
about the profile and it refuses. Those refusals are part of the demo
video.

## Reproduce from scratch

Delete the room and both agents, run the template again from this file,
copy the fixtures, and say `scout, check for new postings.` The whole
setup is this one YAML file plus the fixtures folder.

## Submission

Demo video: `docs/demo-script.md` (script reviewed before recording).
Room template: `application-desk.template.yaml`. This README points at
both rather than explaining them.
