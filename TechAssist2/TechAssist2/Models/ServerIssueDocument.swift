//
//  ServerIssueDocument.swift
//  TechAssist2
//
//  Hard-coded playbooks for the most common data center incidents.
//

import Foundation

struct ServerIssueDocument: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let symptoms: [String]
    let immediateActions: [String]
    let resolutionSteps: [String]
    let validationSteps: [String]
    let safetyNotes: [String]
    let escalationGuidance: String
    let recommendedTools: [String]
    let estimatedTimeMinutes: Int
}

enum ServerIssueDocumentLibrary {
    enum DocumentID: String, CaseIterable {
        case powerSupplyFailure = "power_supply_failure"
        case thermalEvent = "thermal_event"
        case networkOutage = "network_outage"
        case raidDegradation = "raid_degradation"
        case firmwareMismatch = "firmware_mismatch"
    }
    
    static let documents: [DocumentID: ServerIssueDocument] = [
        .powerSupplyFailure: ServerIssueDocument(
            id: DocumentID.powerSupplyFailure.rawValue,
            title: "Power Supply Failure Response",
            summary: "Server unexpectedly powered off due to a failed PSU. Replace the unit and validate load balancing across redundant power feeds.",
            symptoms: [
                "Server is powered off or cycling unexpectedly",
                "Amber or red PSU LED indicator",
                "IPMI/DRAC logs show PSU failure alerts",
                "Power metrics show uneven A/B feed consumption"
            ],
            immediateActions: [
                "Verify the server is currently powered off and safe to service",
                "Confirm redundant power feed status before disconnecting any cables",
                "Notify impacted stakeholders of the outage and expected downtime"
            ],
            resolutionSteps: [
                "Disconnect the failed PSU from both A/B feeds and allow capacitors to discharge (minimum 30 seconds)",
                "Remove the failed PSU and inspect connectors for scorching or debris",
                "Install the replacement PSU that matches wattage and vendor specifications",
                "Reconnect power feeds starting with the redundant feed, then primary",
                "Monitor boot sequence through out-of-band management console"
            ],
            validationSteps: [
                "Confirm redundant PSU health in IPMI/DRAC dashboard",
                "Check real-time power draw to ensure load is evenly distributed",
                "Run quick hardware diagnostics to confirm no additional faults",
                "Update work order logs with replacement PSU serial number"
            ],
            safetyNotes: [
                "Always wear an ESD strap when handling PSU modules",
                "Verify both power feeds are de-energized before removing the module",
                "Use two-person lift for PSUs heavier than 20 lbs"
            ],
            escalationGuidance: "Escalate to the electrical engineering team if feeder voltage is unstable or multiple PSUs fail within 24 hours.",
            recommendedTools: [
                "Replacement PSU module",
                "ESD wrist strap and mat",
                "Torque screwdriver set",
                "Flashlight for rear rack inspection"
            ],
            estimatedTimeMinutes: 45
        ),
        .thermalEvent: ServerIssueDocument(
            id: DocumentID.thermalEvent.rawValue,
            title: "Thermal Event / Overheating Playbook",
            summary: "Rapid temperature increase detected in a cold aisle. Restore airflow, validate CRAC performance, and protect adjacent equipment.",
            symptoms: [
                "Rack inlet temperature > 32°C (90°F)",
                "CRAC unit reporting high discharge temperature",
                "Multiple servers throttling CPU frequencies or shutting down",
                "Hot aisle return sensors exceeding baseline by > 10°C"
            ],
            immediateActions: [
                "Validate readings with handheld thermal sensor to confirm alert accuracy",
                "Check for tripped breakers or alarms on nearby CRAC units",
                "Open ticket with facilities if chilled water or refrigerant lines show anomalies"
            ],
            resolutionSteps: [
                "Inspect and clear floor tiles/vents for obstructions within the affected aisle",
                "Verify CRAC filters and fan belts; replace if clogged or damaged",
                "Force restart of the impacted CRAC unit following manufacturer guidelines",
                "Temporarily redistribute high-heat servers to alternate racks when possible",
                "Review DCIM dashboards for airflow imbalances or closed containment panels"
            ],
            validationSteps: [
                "Trend inlet temperatures for 30 minutes to confirm downward trajectory",
                "Ensure humidity stays within 45-55% to avoid condensation risks",
                "Re-run thermal camera sweep to confirm hotspots are cleared",
                "Document actions and note any recurring maintenance needs"
            ],
            safetyNotes: [
                "Do not leave containment doors open longer than necessary",
                "Beware of slippery floors from condensate drains",
                "Report any refrigerant odors immediately and evacuate if necessary"
            ],
            escalationGuidance: "Contact facilities lead if CRAC does not stabilize within 10 minutes or if chilled water pressure remains outside nominal range.",
            recommendedTools: [
                "Infrared thermal camera",
                "Multimeter with temperature probe",
                "Replacement CRAC filters",
                "Ratchet set for panel access"
            ],
            estimatedTimeMinutes: 30
        ),
        .networkOutage: ServerIssueDocument(
            id: DocumentID.networkOutage.rawValue,
            title: "Core Router / Backbone Outage SOP",
            summary: "Critical core networking gear offline causing multi-tenant impact. Restore connectivity and validate routing tables.",
            symptoms: [
                "Core router shows no link lights or status LEDs solid amber",
                "SNMP traps report chassis heartbeat failure",
                "Multiple customer circuits experiencing packet loss or total outage",
                "NOC reports dynamic routing instability across regions"
            ],
            immediateActions: [
                "Engage maintenance window protocol and notify NOC of onsite activity",
                "Verify redundant supervisors or line cards status via console",
                "Pull syslogs from the standby chassis for error correlation"
            ],
            resolutionSteps: [
                "Connect via console cable and capture last known error messages",
                "Power-cycle the failed router following vendor cold-start procedure",
                "If power cycle fails, reseat supervisor modules and high-priority line cards",
                "Swap to hot spare chassis if MTTR exceeds contractual SLA",
                "Reload saved configuration and confirm BGP/OSPF neighbors re-establish"
            ],
            validationSteps: [
                "Confirm all uplink ports show green link status",
                "Run smoke tests for top customer VLANs and latency benchmarks",
                "Validate routing table convergence and absence of flapping routes",
                "Document outage timeline and corrective actions in incident tracker"
            ],
            safetyNotes: [
                "Use proper lifting techniques for chassis components above 30 lbs",
                "Ensure antistatic precautions when handling supervisor modules",
                "Coordinate with NOC before disconnecting redundant links"
            ],
            escalationGuidance: "Escalate to network architecture on-call if convergence fails after two attempts or if configuration corruption is suspected.",
            recommendedTools: [
                "USB console cable with adapters",
                "Replacement supervisor module",
                "Label maker for cable verification",
                "Torque wrench for line-card seating"
            ],
            estimatedTimeMinutes: 60
        ),
        .raidDegradation: ServerIssueDocument(
            id: DocumentID.raidDegradation.rawValue,
            title: "RAID Degradation / Disk Failure Playbook",
            summary: "Storage array reports degraded RAID set due to failed drive. Replace the disk and monitor rebuild to protect redundancy.",
            symptoms: [
                "Storage controller alerts for degraded or failed RAID volume",
                "Amber LED on drive sled, audible alarm triggered",
                "Host operating system logging read/write retries",
                "SMART metrics showing reallocated sectors exceeding threshold"
            ],
            immediateActions: [
                "Confirm the correct slot using the storage management interface",
                "Notify application owners about reduced redundancy and potential performance impact",
                "Verify backup status or replication health before proceeding"
            ],
            resolutionSteps: [
                "Label and remove the failed drive after ensuring the replacement is ready",
                "Insert the new drive firmly until latch clicks and LED turns green",
                "Acknowledge the replacement in the storage management console",
                "Monitor RAID rebuild progress and ensure no additional errors occur",
                "Adjust hot spare assignments if required by policy"
            ],
            validationSteps: [
                "Confirm RAID returns to optimal state and rebuild reaches 100%",
                "Run targeted read/write test on the volume to validate performance",
                "Update asset inventory with new drive serial number",
                "Close maintenance notification with final status"
            ],
            safetyNotes: [
                "Use two hands when removing drives to avoid damaging connectors",
                "Avoid placing removed drives on conductive surfaces",
                "Allow drives to acclimate to room temperature to prevent condensation"
            ],
            escalationGuidance: "Escalate to storage engineering if a second drive in the array shows pre-failure SMART metrics or rebuild exceeds expected duration.",
            recommendedTools: [
                "Replacement drive sled",
                "ESD-safe drive tray",
                "Label printer for drive identification",
                "Flashlight for rear cabling verification"
            ],
            estimatedTimeMinutes: 35
        ),
        .firmwareMismatch: ServerIssueDocument(
            id: DocumentID.firmwareMismatch.rawValue,
            title: "Firmware Mismatch / Boot Failure Guide",
            summary: "Server fails to boot after maintenance due to inconsistent firmware levels. Align firmware and restore service.",
            symptoms: [
                "POST sequence halts with firmware mismatch error",
                "Lifecycle controller shows incompatible driver pack",
                "Server stuck in boot loop after recent component swap",
                "Out-of-band management reports invalid BIOS/Controller combination"
            ],
            immediateActions: [
                "Capture current firmware versions from lifecycle controller or BIOS",
                "Roll back any recent firmware updates if recovery image is available",
                "Notify stakeholders about expected downtime during remediation"
            ],
            resolutionSteps: [
                "Download the vendor-approved firmware bundle for the exact server model",
                "Apply firmware updates in recommended order: BIOS → RAID → NIC → iDRAC",
                "If system still fails, perform NVRAM reset following vendor guidelines",
                "Reapply saved configuration profiles and boot settings",
                "Document firmware baseline to prevent future drift"
            ],
            validationSteps: [
                "Confirm server completes full POST and boots into operating system",
                "Run firmware inventory report to ensure versions match baseline",
                "Execute quick stress test to confirm stability",
                "Update configuration management database with final firmware versions"
            ],
            safetyNotes: [
                "Use redundant power during firmware updates to prevent corruption",
                "Do not interrupt firmware flash once initiated",
                "Maintain secure storage of firmware packages to avoid tampering"
            ],
            escalationGuidance: "Engage vendor support if firmware flash fails twice or if hardware replacement is required to resolve corruption.",
            recommendedTools: [
                "Bootable firmware ISO or USB media",
                "Out-of-band management laptop",
                "Label set for firmware baseline tracking",
                "Static-safe storage for removed components"
            ],
            estimatedTimeMinutes: 50
        )
    ]
    
    static func document(for id: String?) -> ServerIssueDocument? {
        guard let id = id else { return nil }
        return DocumentID(rawValue: id).flatMap { documents[$0] }
    }
}


