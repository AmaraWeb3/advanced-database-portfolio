// =====================================================================
// Portfolio 5: Distributed and Cloud Database Exercise
// File: 04_read_node.js
//
// PURPOSE
// Connect directly to ONE node and read the catalogue from it. This
// proves that a secondary holds its own copy of the data.
//
// HOW TO RUN (against a specific node, no replica set address)
//   docker exec -it mongo2 mongosh --quiet --file /tmp/04_read_node.js
//   docker exec -it mongo3 mongosh --quiet --file /tmp/04_read_node.js
// =====================================================================

// Allow reads from a secondary node
db.getMongo().setReadPref("secondaryPreferred");

db = db.getSiblingDB("library_dist");

print("Connected node:  " + db.hello().me);
print("Is secondary:    " + db.hello().secondary);
print("Books on this node: " + db.books.countDocuments());
