// =====================================================================
// Portfolio 5: Distributed and Cloud Database Exercise
// File: 02_rs_status.js
//
// PURPOSE
// Print the state of every member of the replica set rs0:
// PRIMARY, SECONDARY, or not reachable.
//
// HOW TO RUN (against any node that is currently running)
//   docker exec -it mongo2 mongosh --quiet --file /tmp/02_rs_status.js
// =====================================================================

const status = rs.status();

print("Replica set: " + status.set);
print("Checked at:  " + new Date().toISOString());
print("");

status.members.forEach(function (m) {
  print(m.name + "   " + m.stateStr + "   health=" + m.health);
});
