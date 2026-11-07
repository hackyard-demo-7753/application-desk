# Build plan (Nov 4-7 IST)

Day 1 (Nov 4) - de-risk in this order:
1. Run the template end to end on the host machine. If the YAML does not
   create agents + room + kickoff in one run, nothing else matters.
2. Prove the boundary: writer asked to fetch a posting refuses; scout
   asked for the profile says it does not have it.
3. Prove the gate: writer does not finalize without the approver's
   explicit named approval; approval moves the package and appends to
   the Tracker.
4. Tracker entry is a room doc artifact, not a human note.

Day 2 (Nov 5) - polish the workflow: two fixture postings flow end to end,
rejection path (posting-02) records a one-line reason, room instructions
tuned from what the agents actually did.

Day 3 (Nov 6) - clean-room run: delete room and agents, re-run from the
committed template exactly as a judge would. Fix whatever it finds.
Finalize demo script with the user (review gate), then record.

Day 4 (Nov 7) - README pass, repo tidy, submit before 23:59 IST. Buffer
the morning for re-recording.
