// =====================================================================
// Portfolio 5: Distributed and Cloud Database Exercise
// Case study: Rivers City Public Library Management System (simulated)
// File: 01_replica_init.js
//
// PURPOSE
// Turn three MongoDB containers (mongo1, mongo2, mongo3) into one
// replica set called rs0. One node becomes the PRIMARY (accepts writes)
// and the other two become SECONDARIES (copy the primary's data).
//
// HOW TO RUN (once, against mongo1)
//   docker exec -it mongo1 mongosh --quiet --file /tmp/01_replica_init.js
//
// Running it twice gives an "already initialized" error, which is normal.
// =====================================================================

const result = rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017" },
    { _id: 1, host: "mongo2:27017" },
    { _id: 2, host: "mongo3:27017" }
  ]
});

printjson(result);
