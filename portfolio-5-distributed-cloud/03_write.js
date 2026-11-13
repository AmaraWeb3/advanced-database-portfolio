// =====================================================================
// Portfolio 5: Distributed and Cloud Database Exercise
// File: 03_write.js
//
// PURPOSE
// Write one catalogue record to the replica set and show which node
// accepted the write. The write uses writeConcern "majority", so it is
// only acknowledged once at least 2 of the 3 nodes have it.
//
// HOW TO RUN (using the replica set address, so the shell finds the
// current primary by itself)
//   docker exec -it mongo2 mongosh --quiet "mongodb://mongo2:27017,mongo3:27017/?replicaSet=rs0" --file /tmp/03_write.js
// =====================================================================

db = db.getSiblingDB("library_dist");

const outcome = db.books.insertOne(
  {
    title: "Replication test " + new Date().toISOString(),
    branch: "Port Harcourt Main",
    note: "Catalogue record used to test replication and failover"
  },
  { writeConcern: { w: "majority" } }
);

print("Write acknowledged: " + outcome.acknowledged);
print("Total books in library_dist: " + db.books.countDocuments());
print("Write was accepted by: " + db.hello().me);
print("Current primary is:    " + db.hello().primary);
