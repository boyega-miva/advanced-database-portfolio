// Insert Polymorphic Cold-Chain Telemetry Document
db.ShipmentTelematics.insertMany([
  {
    "_id": "SHIP-LAG-KAN-2026-00491",
    "carrier_metadata": {
      "provider": "Apex Cold Chain Logistics",
      "vehicle_plate": "EPE-491-XA"
    },
    "package_specifications": {
      "target_temp_range": { "min_celsius": -20.0, "max_celsius": -15.0 }
    },
    "telemetry_stream": [
      {
        "sequence_idx": 1,
        "timestamp": "2026-10-12T10:00:00Z",
        "gps": { "lat": 6.5244, "lng": 3.3792 },
        "metrics": { "core_temp": -18.2, "battery_pct": 98.4 },
        "tamper_detected": false
      },
      {
        "sequence_idx": 2,
        "timestamp": "2026-10-12T10:15:00Z",
        "gps": { "lat": 6.6018, "lng": 3.3515 },
        "metrics": { "core_temp": -13.8, "battery_pct": 97.9 },
        "tamper_detected": true
      }
    ]
  }
]);

// Run aggregation to catch temperature breaches (core_temp > -15.0 C)
db.ShipmentTelematics.aggregate([
  { $unwind: "$telemetry_stream" },
  { $match: { "telemetry_stream.metrics.core_temp": { $gt: -15.0 } } },
  {
    $group: {
      "_id": "$_id",
      "carrier": { $first: "$carrier_metadata.provider" },
      "highest_breach_temp": { $max: "$telemetry_stream.metrics.core_temp" },
      "breach_incidents": { $sum: 1 }
    }
  }
]);
