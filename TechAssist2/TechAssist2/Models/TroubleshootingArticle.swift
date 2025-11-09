//
//  TroubleshootingArticle.swift
//  TechAssist2
//
//  Troubleshooting Article Data Model
//

import Foundation
import SwiftUI

struct TroubleshootingArticle: Identifiable, Hashable {
    let id: UUID
    let title: String
    let stack: String
    let category: String
    let content: String
    let tags: [String]
    let lastUpdated: Date
    let qrCodeID: String // QR code identifier for scanning
    
    init(
        id: UUID = UUID(),
        title: String,
        stack: String,
        category: String,
        qrCodeID: String,
        content: String,
        tags: [String] = [],
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.stack = stack
        self.category = category
        self.qrCodeID = qrCodeID
        self.content = content
        self.tags = tags
        self.lastUpdated = lastUpdated
    }
}

// Troubleshooting Articles Data
extension TroubleshootingArticle {
    static let allArticles: [TroubleshootingArticle] = [
        .psuFailureTroubleshooting,
        .coolingSystemTroubleshooting,
        .networkInfrastructureTroubleshooting,
        .serverHardwareTroubleshooting,
        .upsPowerTroubleshooting
    ]
    
    /// Find article by QR code ID
    static func findArticle(byQRCodeID qrCodeID: String) -> TroubleshootingArticle? {
        return allArticles.first { article in
            article.qrCodeID.lowercased() == qrCodeID.lowercased()
        }
    }
    
    static let psuFailureTroubleshooting = TroubleshootingArticle(
        title: "Power Supply Unit (PSU) Failure Troubleshooting",
        stack: "Power Systems",
        category: "Data Center Hardware",
        qrCodeID: "PSU",
        content: """
        # Power Supply Unit (PSU) Failure Troubleshooting Guide
        
        ## Common PSU Failure Symptoms
        
        ### 1. Server Unexpectedly Shuts Down
        **Problem:** Server powers off without warning, no error messages
        
        **Diagnosis:**
        - Check PSU LED indicators (green = OK, red/amber = failure)
        - Verify both PSUs in redundant configuration
        - Check server logs for power-related errors
        - Measure voltage output with multimeter (should be 12V, 5V, 3.3V)
        
        **Solution:**
        - Identify which PSU has failed (check status LEDs)
        - Power down server safely if single PSU configuration
        - Remove failed PSU and replace with identical model
        - Verify replacement PSU is same wattage rating
        - Test with load before returning to production
        
        ### 2. Intermittent Power Issues
        **Problem:** Server restarts randomly or shows power warnings
        
        **Diagnosis:**
        - Check for loose power cable connections
        - Verify PSU is receiving adequate input voltage (100-240V AC)
        - Inspect power cables for damage or fraying
        - Check PSU fan operation (overheating can cause failures)
        - Review server event logs for power events
        
        **Solution:**
        - Tighten all power connections
        - Replace damaged power cables
        - Clean PSU fan and vents (dust accumulation)
        - Verify adequate airflow around PSU
        - Replace PSU if issues persist
        
        ### 3. PSU Fan Failure
        **Problem:** Loud noise, overheating, or PSU thermal shutdown
        
        **Diagnosis:**
        - Listen for unusual fan noises (grinding, rattling)
        - Check PSU temperature (should be < 50°C)
        - Verify fan is spinning (visual inspection)
        - Check for dust blocking fan intake
        
        **Solution:**
        - Clean PSU fan and intake vents
        - Replace PSU if fan is not operational
        - Ensure adequate cooling in rack environment
        - Verify hot-aisle/cold-aisle configuration
        
        ### 4. Voltage Regulation Issues
        **Problem:** Server instability, data corruption, or component failures
        
        **Diagnosis:**
        - Use multimeter to test voltage outputs
        - Check for voltage fluctuations (should be ±5% of rated voltage)
        - Monitor server logs for voltage warnings
        - Test with known good PSU if available
        
        **Solution:**
        - Replace PSU if voltage is outside tolerance
        - Verify power source (UPS, PDU) is functioning correctly
        - Check for power load issues (overloaded circuit)
        - Replace PSU with higher wattage if underpowered
        
        ### 5. PSU Not Recognized by System
        **Problem:** Server doesn't detect PSU or shows "PSU Not Present"
        
        **Diagnosis:**
        - Check PSU connection to motherboard
        - Verify PSU is fully seated in chassis
        - Check for damaged connector pins
        - Review server management interface (iDRAC, iLO, etc.)
        
        **Solution:**
        - Reseat PSU in chassis
        - Check and clean connector contacts
        - Verify PSU is compatible with server model
        - Replace PSU if connector is damaged
        - Update server firmware if compatibility issue
        
        ## Safety Procedures
        
        ### Before Replacement
        - Power down server properly (graceful shutdown)
        - Disconnect all power cables
        - Wait 30 seconds for capacitors to discharge
        - Wear ESD strap to prevent static damage
        - Verify replacement PSU matches specifications
        
        ### During Replacement
        - Document PSU model and serial number
        - Remove failed PSU carefully (may be hot)
        - Install replacement PSU securely
        - Connect all power cables firmly
        - Verify PSU is properly seated
        
        ### After Replacement
        - Power on server and verify PSU status LEDs
        - Check server management interface for PSU status
        - Monitor server for 15-30 minutes
        - Verify no error messages in logs
        - Update documentation with replacement information
        
        ## Preventive Maintenance
        
        ### Regular Checks
        - Monthly visual inspection of PSUs
        - Quarterly cleaning of PSU fans and vents
        - Annual testing of redundant PSU configuration
        - Monitor PSU temperature and fan speeds
        - Keep spare PSUs in inventory
        
        ### Best Practices
        - Use redundant PSU configuration when possible
        - Connect PSUs to separate power circuits
        - Maintain proper environmental conditions (temperature, humidity)
        - Keep PSU firmware updated
        - Document all PSU replacements
        
        ## Required Tools
        
        - Multimeter (voltage testing)
        - ESD strap and mat
        - Screwdrivers (Phillips, flathead)
        - Flashlight (inspection)
        - Compressed air (cleaning)
        - Replacement PSU (matching specifications)
        
        ## Common PSU Models
        
        - Dell: 495W, 750W, 1100W, 1600W
        - HP: 460W, 800W, 1200W, 1600W
        - IBM/Lenovo: 550W, 900W, 1400W
        - Always verify compatibility with server model
        """,
        tags: ["PSU", "Power Supply", "Hardware", "Data Center", "Server", "Electrical", "Failure"],
        lastUpdated: Date(),
        //qrCodeID: "PSU"
    )
    
    static let coolingSystemTroubleshooting = TroubleshootingArticle(
        title: "Cooling System (CRAC) Failure Troubleshooting",
        stack: "HVAC Systems",
        category: "Data Center Infrastructure",
        qrCodeID: "CRAC",
        content: """
        # Cooling System (CRAC) Failure Troubleshooting Guide
        
        ## Common CRAC Unit Issues
        
        ### 1. Temperature Spikes
        **Problem:** Data center temperature rising above threshold (typically > 80°F/27°C)
        
        **Diagnosis:**
        - Check CRAC unit status (running, error codes)
        - Verify temperature sensors are functioning
        - Check for blocked air intake or exhaust
        - Verify refrigerant levels (if applicable)
        - Check condenser coils for dirt/debris
        - Monitor temperature trends in monitoring system
        
        **Solution:**
        - Restart CRAC unit if it has stopped
        - Clean air filters and condenser coils
        - Clear any obstructions blocking airflow
        - Verify adequate refrigerant (call HVAC technician if low)
        - Check for failed compressors or fans
        - Ensure proper hot-aisle/cold-aisle containment
        
        ### 2. CRAC Unit Not Cooling
        **Problem:** Unit running but not producing cold air
        
        **Diagnosis:**
        - Check discharge air temperature (should be 55-65°F)
        - Verify compressor is running (listen for noise)
        - Check refrigerant pressure (requires HVAC technician)
        - Inspect evaporator coils for ice buildup
        - Verify water flow (for water-cooled units)
        - Check for error codes on control panel
        
        **Solution:**
        - Defrost evaporator coils if iced over
        - Check refrigerant levels and recharge if needed
        - Verify water flow and pressure (water-cooled systems)
        - Clean evaporator and condenser coils
        - Replace failed compressor or fan motor
        - Call HVAC technician for refrigerant issues
        
        ### 3. High Humidity Levels
        **Problem:** Humidity above recommended range (40-60% RH)
        
        **Diagnosis:**
        - Check humidity sensors and calibration
        - Verify dehumidification system is operational
        - Check for water leaks or standing water
        - Monitor humidity trends
        - Verify outside air intake is properly controlled
        
        **Solution:**
        - Activate dehumidification mode on CRAC unit
        - Fix any water leaks
        - Remove standing water
        - Adjust outside air intake (reduce if too humid)
        - Calibrate humidity sensors
        - Service dehumidification components
        
        ### 4. Low Humidity Levels
        **Problem:** Humidity below recommended range (< 40% RH)
        
        **Diagnosis:**
        - Check humidity sensors
        - Verify humidification system is operational
        - Check water supply to humidifier
        - Monitor for static electricity issues
        - Verify outside air conditions
        
        **Solution:**
        - Activate humidification mode on CRAC unit
        - Verify water supply to humidifier
        - Check and clean humidifier components
        - Calibrate humidity sensors
        - Service humidification system if needed
        
        ### 5. CRAC Unit Not Starting
        **Problem:** Unit won't power on or immediately shuts down
        
        **Diagnosis:**
        - Check power supply (circuit breaker, power cable)
        - Verify control panel for error codes
        - Check safety interlocks (door switches, pressure switches)
        - Verify water flow (water-cooled systems)
        - Check for overload conditions
        - Review unit logs and alarms
        
        **Solution:**
        - Reset circuit breaker if tripped
        - Check and reset safety interlocks
        - Verify adequate water flow and pressure
        - Clear any error codes
        - Check for mechanical obstructions
        - Contact HVAC technician if electrical issues
        
        ## Emergency Procedures
        
        ### Temperature Emergency
        - Activate emergency cooling procedures
        - Open doors to improve airflow (if safe)
        - Reduce server load if possible
        - Deploy portable cooling units
        - Notify facilities and management
        - Monitor temperature continuously
        
        ### CRAC Unit Failure
        - Verify redundant units are operational
        - Redistribute cooling load if possible
        - Deploy portable cooling units
        - Notify HVAC maintenance immediately
        - Monitor temperature and humidity
        - Prepare for potential server shutdown
        
        ## Preventive Maintenance
        
        ### Daily Checks
        - Monitor temperature and humidity levels
        - Check CRAC unit status and alarms
        - Verify airflow patterns
        - Check for water leaks
        
        ### Weekly Checks
        - Clean air filters
        - Inspect condenser coils
        - Check refrigerant lines for leaks
        - Verify fan operation
        - Test alarm systems
        
        ### Monthly Checks
        - Deep clean condenser and evaporator coils
        - Check refrigerant levels
        - Calibrate temperature and humidity sensors
        - Verify control system operation
        - Test backup systems
        
        ### Quarterly Checks
        - Service compressors and fans
        - Check electrical connections
        - Verify water quality (water-cooled systems)
        - Test emergency procedures
        - Review and update maintenance logs
        
        ## Required Tools and Equipment
        
        - Temperature and humidity meters
        - Refrigerant pressure gauges (HVAC technician)
        - Air filter replacements
        - Coil cleaning supplies
        - Multimeter (electrical testing)
        - Flashlight and inspection tools
        - Portable cooling units (emergency)
        
        ## Best Practices
        
        ### Cooling Configuration
        - Maintain hot-aisle/cold-aisle configuration
        - Use blanking panels in empty rack spaces
        - Ensure proper airflow under raised floor
        - Seal cable penetrations
        - Use containment systems when possible
        
        ### Monitoring
        - Install temperature sensors throughout data center
        - Monitor CRAC unit performance metrics
        - Set up alerts for temperature and humidity
        - Track energy consumption
        - Maintain maintenance logs
        
        ### Redundancy
        - Install redundant CRAC units (N+1 configuration)
        - Connect to separate power circuits
        - Use different cooling technologies if possible
        - Test failover procedures regularly
        - Maintain spare parts inventory
        """,
        tags: ["CRAC", "Cooling", "HVAC", "Temperature", "Data Center", "Infrastructure", "Climate Control"],
        lastUpdated: Date(),
        //qrCodeID: "CRAC"
    )
    
    static let networkInfrastructureTroubleshooting = TroubleshootingArticle(
        title: "Network Infrastructure Troubleshooting Guide",
        stack: "Networking",
        category: "Data Center Infrastructure",
        qrCodeID: "NETWORK",
        content: """
        # Network Infrastructure Troubleshooting Guide
        
        ## Common Network Issues
        
        ### 1. Network Connectivity Loss
        **Problem:** Servers cannot communicate, network is down
        
        **Diagnosis:**
        - Check switch/router status LEDs
        - Verify power to network equipment
        - Check for link lights on network interfaces
        - Test connectivity with ping and traceroute
        - Review switch logs for errors
        - Check for spanning tree protocol (STP) issues
        - Verify no loops in network topology
        
        **Solution:**
        - Power cycle network equipment if unresponsive
        - Check and replace failed network cables
        - Verify switch ports are enabled and configured correctly
        - Clear STP loops if detected
        - Replace failed network interface cards (NICs)
        - Check for firmware issues and update if needed
        - Verify VLAN configuration is correct
        
        ### 2. Slow Network Performance
        **Problem:** Network is slow, high latency, packet loss
        
        **Diagnosis:**
        - Check bandwidth utilization (should be < 70%)
        - Verify network interface errors (collisions, CRC errors)
        - Check for duplex mismatches
        - Monitor packet loss with ping and iperf
        - Review switch CPU and memory utilization
        - Check for broadcast storms
        - Verify MTU size is consistent
        
        **Solution:**
        - Fix duplex mismatches (set to auto-negotiate or manual)
        - Replace faulty network cables
        - Update network drivers and firmware
        - Clear broadcast storms
        - Upgrade network equipment if bandwidth is insufficient
        - Optimize network topology
        - Check for network congestion and redistribute load
        
        ### 3. Intermittent Connection Issues
        **Problem:** Connections work sometimes but drop frequently
        
        **Diagnosis:**
        - Check for loose cable connections
        - Verify cable integrity (no damage, proper length)
        - Check for electromagnetic interference (EMI)
        - Monitor for interface errors over time
        - Verify cable specifications (Cat5e, Cat6, etc.)
        - Check for port flapping in switch logs
        - Test with known good cables
        
        **Solution:**
        - Reseat all network connections
        - Replace damaged or faulty cables
        - Use shielded cables if EMI is suspected
        - Verify cable length is within specifications
        - Replace faulty switch ports
        - Update network drivers
        - Check for power issues affecting network equipment
        
        ### 4. VLAN Configuration Issues
        **Problem:** Devices cannot communicate across VLANs or within VLAN
        
        **Diagnosis:**
        - Verify VLAN configuration on switches
        - Check trunk port configuration
        - Verify VLAN IDs match across network
        - Check router/firewall VLAN configuration
        - Verify switch port VLAN assignments
        - Test connectivity within and between VLANs
        - Review routing table configuration
        
        **Solution:**
        - Correct VLAN assignments on switch ports
        - Verify trunk ports are configured correctly
        - Ensure VLAN IDs are consistent across network
        - Configure inter-VLAN routing if needed
        - Update VLAN configuration documentation
        - Test VLAN connectivity after changes
        
        ### 5. Switch/Router Failure
        **Problem:** Network equipment is unresponsive or has failed
        
        **Diagnosis:**
        - Check power status and LEDs
        - Verify cooling fans are operating
        - Check for error messages on console
        - Verify management interface accessibility
        - Check for overheating (touch test, temperature sensors)
        - Review system logs for errors
        - Test with console cable access
        
        **Solution:**
        - Power cycle equipment if unresponsive
        - Replace failed power supply if needed
        - Clean cooling fans and vents
        - Replace failed equipment if hardware failure
        - Restore configuration from backup
        - Update firmware if software issue
        - Contact vendor support if under warranty
        
        ## Network Troubleshooting Tools
        
        ### Hardware Tools
        - Cable tester (continuity, wire map)
        - Network analyzer (packet capture)
        - Tone generator and probe (cable tracing)
        - Loopback plugs (interface testing)
        - Console cable (switch/router management)
        - Multimeter (power and continuity testing)
        
        ### Software Tools
        - ping (connectivity testing)
        - traceroute (path analysis)
        - iperf (bandwidth testing)
        - Wireshark (packet analysis)
        - nmap (network scanning)
        - netstat (connection status)
        - tcpdump (packet capture)
        
        ## Diagnostic Procedures
        
        ### Layer 1 (Physical) Checks
        - Verify cable connections are secure
        - Check cable integrity (no damage, proper type)
        - Verify link lights on network interfaces
        - Test cables with cable tester
        - Check power to network equipment
        - Verify cable length is within specifications
        
        ### Layer 2 (Data Link) Checks
        - Verify switch port status (up/down)
        - Check for MAC address table issues
        - Verify STP is functioning correctly
        - Check for VLAN configuration issues
        - Monitor for interface errors
        - Verify duplex and speed settings
        
        ### Layer 3 (Network) Checks
        - Verify IP addressing configuration
        - Check routing table entries
        - Test connectivity with ping
        - Verify subnet masks are correct
        - Check for routing protocol issues
        - Verify firewall rules
        
        ## Preventive Maintenance
        
        ### Regular Checks
        - Monitor network performance metrics
        - Review switch logs for errors
        - Verify backup configurations are current
        - Test failover procedures
        - Update firmware and software
        - Clean network equipment
        
        ### Documentation
        - Maintain network topology diagrams
        - Document VLAN configurations
        - Record IP address assignments
        - Update cable run documentation
        - Maintain change logs
        - Document troubleshooting procedures
        
        ## Best Practices
        
        ### Network Design
        - Use redundant network paths
        - Implement proper VLAN segmentation
        - Use link aggregation for bandwidth
        - Configure STP properly to prevent loops
        - Implement quality of service (QoS) policies
        - Use proper cable management
        
        ### Security
        - Disable unused switch ports
        - Implement port security
        - Use secure management protocols (SSH, not Telnet)
        - Regularly update firmware
        - Monitor for unauthorized devices
        - Implement network access control (NAC)
        """,
        tags: ["Network", "Switch", "Router", "Ethernet", "VLAN", "Connectivity", "Infrastructure"],
        lastUpdated: Date(),
        // qrCodeID: "NETWORK"
    )
    
    static let serverHardwareTroubleshooting = TroubleshootingArticle(
        title: "Server Hardware Failure Troubleshooting",
        stack: "Server Hardware",
        category: "Data Center Hardware",
        qrCodeID: "SERVER",
        content: """
        # Server Hardware Failure Troubleshooting Guide
        
        ## Common Server Hardware Issues
        
        ### 1. Server Won't Power On
        **Problem:** Server does not respond to power button, no lights or fans
        
        **Diagnosis:**
        - Check power cable connection
        - Verify power outlet is working
        - Check PSU status LEDs
        - Verify circuit breaker hasn't tripped
        - Check for blown fuses in PSU
        - Test with known good PSU if available
        - Verify front panel power button connection
        
        **Solution:**
        - Reseat power cables firmly
        - Test with different power outlet
        - Replace failed PSU
        - Reset circuit breaker if tripped
        - Check and replace front panel connections
        - Verify PSU wattage is adequate for server
        - Replace motherboard if PSU is good but server won't power on
        
        ### 2. Server Crashes or Blue Screen
        **Problem:** Server unexpectedly crashes, shows blue screen (Windows) or kernel panic (Linux)
        
        **Diagnosis:**
        - Check server logs for error messages
        - Review memory diagnostics (run memtest)
        - Check CPU temperature (overheating can cause crashes)
        - Verify disk health (SMART status)
        - Check for driver issues
        - Review recent hardware or software changes
        - Check for RAM errors in system logs
        
        **Solution:**
        - Replace faulty RAM modules (test individually)
        - Clean CPU heatsink and reapply thermal paste
        - Replace failed hard drive or SSD
        - Update device drivers
        - Roll back recent changes if possible
        - Update server firmware and BIOS
        - Replace faulty motherboard if issues persist
        
        ### 3. Overheating Issues
        **Problem:** Server shuts down due to overheating, high temperature warnings
        
        **Diagnosis:**
        - Check CPU and system temperature in BIOS/UEFI
        - Verify all fans are spinning
        - Check for dust blocking air vents
        - Verify adequate airflow in rack
        - Check thermal paste on CPU
        - Monitor temperature over time
        - Verify hot-aisle/cold-aisle configuration
        
        **Solution:**
        - Clean server fans and air vents
        - Replace failed fans
        - Reapply thermal paste on CPU
        - Improve rack airflow (blanking panels, cable management)
        - Reduce server load if possible
        - Verify ambient temperature is within range
        - Replace faulty temperature sensors
        
        ### 4. Disk Drive Failures
        **Problem:** Disk errors, data corruption, or disk not detected
        
        **Diagnosis:**
        - Check disk status in RAID controller
        - Review SMART status for disk health
        - Check disk cables and connections
        - Verify disk is detected in BIOS/UEFI
        - Check for disk errors in system logs
        - Test disk with manufacturer diagnostics
        - Verify disk is properly seated in bay
        
        **Solution:**
        - Replace failed disk drive
        - Reseat disk cables
        - Replace faulty disk cables
        - Rebuild RAID array if disk replaced
        - Restore data from backup if needed
        - Verify disk compatibility with server
        - Update RAID controller firmware
        
        ### 5. Memory (RAM) Errors
        **Problem:** Memory errors, system instability, or server won't boot
        
        **Diagnosis:**
        - Run memory diagnostics (memtest86, Windows Memory Diagnostic)
        - Check system logs for memory errors
        - Verify RAM is properly seated
        - Check for compatible RAM speed and type
        - Test RAM modules individually
        - Verify RAM configuration (single/dual channel)
        - Check for overheating RAM modules
        
        **Solution:**
        - Reseat RAM modules
        - Replace faulty RAM modules
        - Verify RAM is compatible with server
        - Update BIOS/UEFI for RAM compatibility
        - Replace RAM in pairs for dual channel
        - Clean RAM contacts if dirty
        - Replace motherboard if RAM slots are faulty
        
        ### 6. Network Interface Card (NIC) Failure
        **Problem:** Network connectivity issues, NIC not detected
        
        **Diagnosis:**
        - Check NIC status in operating system
        - Verify NIC is detected in BIOS/UEFI
        - Check for link lights on network port
        - Test with different network cable
        - Verify NIC drivers are installed
        - Check for NIC errors in system logs
        - Test with known good NIC if available
        
        **Solution:**
        - Update NIC drivers
        - Replace failed NIC (if add-on card)
        - Reseat NIC if it's an add-on card
        - Replace motherboard if onboard NIC failed
        - Verify NIC compatibility with server
        - Configure NIC settings correctly
        - Update server firmware
        
        ## Diagnostic Procedures
        
        ### Power-On Self-Test (POST)
        - Listen for POST beep codes
        - Check POST error messages on screen
        - Verify all components are detected
        - Check for hardware configuration errors
        - Review POST logs in system management
        
        ### System Management Interface
        - Access iDRAC (Dell), iLO (HP), or IMM (IBM/Lenovo)
        - Review hardware status and errors
        - Check temperature and fan speeds
        - Review system event logs
        - Run remote diagnostics
        - Check firmware versions
        
        ### Operating System Diagnostics
        - Review system logs for hardware errors
        - Run built-in diagnostic tools
        - Check device manager for device errors
        - Monitor system performance metrics
        - Review application logs for hardware-related errors
        
        ## Replacement Procedures
        
        ### Before Replacement
        - Backup server data and configuration
        - Document current hardware configuration
        - Verify replacement part compatibility
        - Power down server gracefully
        - Disconnect all cables
        - Wear ESD protection
        
        ### During Replacement
        - Document failed component (model, serial number)
        - Remove failed component carefully
        - Install replacement component securely
        - Verify all connections are secure
        - Clean contacts if needed
        - Reapply thermal paste for CPUs
        
        ### After Replacement
        - Power on server and verify POST
        - Check system management interface for errors
        - Verify operating system detects new hardware
        - Update drivers if needed
        - Test server functionality
        - Update documentation
        - Monitor server for 24-48 hours
        
        ## Preventive Maintenance
        
        ### Regular Checks
        - Monthly visual inspection of servers
        - Quarterly cleaning of fans and vents
        - Annual thermal paste replacement (if recommended)
        - Regular firmware updates
        - Monitor hardware health metrics
        - Test backup systems regularly
        
        ### Best Practices
        - Maintain proper environmental conditions
        - Use redundant hardware when possible
        - Keep spare parts inventory
        - Document all hardware changes
        - Update firmware regularly
        - Monitor hardware health continuously
        
        ## Required Tools
        
        - ESD strap and mat
        - Screwdrivers (various sizes)
        - Flashlight
        - Compressed air (cleaning)
        - Thermal paste
        - Multimeter (power testing)
        - POST card (advanced diagnostics)
        - Console cable (management interface)
        
        ## Common Server Components
        
        - Power Supply Units (PSU)
        - Motherboards
        - CPUs and heatsinks
        - Memory (RAM) modules
        - Hard drives and SSDs
        - Network Interface Cards (NIC)
        - RAID controllers
        - Cooling fans
        - Backplanes and cables
        """,
        tags: ["Server", "Hardware", "CPU", "RAM", "Disk", "PSU", "Data Center"],
        lastUpdated: Date(),
        // qrCodeID: "SERVER"
    )
    
    static let upsPowerTroubleshooting = TroubleshootingArticle(
        title: "UPS and Power Distribution Troubleshooting",
        stack: "Power Systems",
        category: "Data Center Infrastructure",
        qrCodeID: "UPS",
        content: """
        # UPS and Power Distribution Troubleshooting Guide
        
        ## Common UPS Issues
        
        ### 1. UPS Battery Failure
        **Problem:** UPS indicates battery failure, won't hold charge, or runtime is reduced
        
        **Diagnosis:**
        - Check UPS battery status LED or display
        - Verify battery age (typically 3-5 years lifespan)
        - Test battery with load test
        - Check battery voltage with multimeter
        - Review UPS event logs for battery warnings
        - Verify battery connections are secure
        - Check for battery swelling or leakage
        
        **Solution:**
        - Replace failed battery modules
        - Replace all batteries in UPS (don't mix old and new)
        - Calibrate UPS after battery replacement
        - Verify battery compatibility with UPS model
        - Update UPS firmware if available
        - Perform battery test after replacement
        - Document battery replacement date
        
        ### 2. UPS Not Providing Backup Power
        **Problem:** UPS doesn't switch to battery during power outage
        
        **Diagnosis:**
        - Verify UPS is in "On" or "Online" mode
        - Check battery status and charge level
        - Test UPS with simulated power failure (unplug from wall)
        - Verify transfer switch is functioning
        - Check for error messages on UPS display
        - Review UPS event logs
        - Verify UPS is not in bypass mode
        
        **Solution:**
        - Charge batteries fully (may take 24-48 hours)
        - Replace failed batteries
        - Repair or replace transfer switch
        - Reset UPS to factory defaults if needed
        - Update UPS firmware
        - Contact UPS manufacturer if internal failure
        - Verify UPS is properly configured
        
        ### 3. UPS Overload
        **Problem:** UPS indicates overload, shuts down, or beeps continuously
        
        **Diagnosis:**
        - Check UPS load percentage (should be < 80%)
        - Calculate total load connected to UPS
        - Verify UPS capacity (VA/Watt rating)
        - Check for additional equipment recently connected
        - Monitor load over time
        - Verify UPS is rated for load
        
        **Solution:**
        - Reduce load on UPS (disconnect non-critical equipment)
        - Upgrade to larger capacity UPS
        - Distribute load across multiple UPS units
        - Verify equipment power consumption
        - Remove faulty equipment drawing excessive power
        - Recalculate load requirements
        
        ### 4. UPS Overheating
        **Problem:** UPS shuts down due to overheating, hot to touch
        
        **Diagnosis:**
        - Check UPS temperature (should be < 104°F/40°C)
        - Verify adequate ventilation around UPS
        - Check for blocked air vents
        - Verify cooling fans are operating
        - Check ambient temperature in UPS room
        - Monitor temperature over time
        
        **Solution:**
        - Improve ventilation around UPS
        - Clean air vents and filters
        - Replace failed cooling fans
        - Reduce ambient temperature
        - Ensure adequate clearance around UPS
        - Relocate UPS if environment is too hot
        - Reduce UPS load if possible
        
        ### 5. Power Distribution Unit (PDU) Issues
        **Problem:** PDU not distributing power, circuit breakers tripping
        
        **Diagnosis:**
        - Check PDU status indicators
        - Verify circuit breakers are not tripped
        - Check total load on PDU (should be < 80% of rating)
        - Verify PDU is receiving power from UPS
        - Check for loose connections
        - Test outlets with outlet tester
        - Monitor PDU load over time
        
        **Solution:**
        - Reset tripped circuit breakers
        - Reduce load on PDU if overloaded
        - Replace failed PDU outlets
        - Tighten loose connections
        - Replace faulty circuit breakers
        - Upgrade to higher capacity PDU
        - Distribute load across multiple PDUs
        
        ## UPS Types and Configurations
        
        ### Standby UPS
        - Switches to battery during power outage
        - Typically used for desktop computers
        - Lower cost, shorter runtime
        - Transfer time: 2-10 milliseconds
        
        ### Line-Interactive UPS
        - Regulates voltage automatically
        - Switches to battery during outages
        - Better for small servers and network equipment
        - Transfer time: 2-4 milliseconds
        
        ### Online/Double-Conversion UPS
        - Always runs on battery (inverter)
        - Best protection and voltage regulation
        - Used for critical servers and equipment
        - No transfer time (zero transfer)
        - Higher cost and lower efficiency
        
        ### Redundant UPS Configuration
        - N+1 configuration (multiple UPS units)
        - Provides redundancy if one UPS fails
        - Load sharing across UPS units
        - Requires proper load balancing
        
        ## Battery Maintenance
        
        ### Regular Testing
        - Monthly battery self-test (automatic)
        - Quarterly manual battery test
        - Annual full load test
        - Monitor battery voltage and temperature
        - Review battery event logs
        
        ### Battery Replacement
        - Replace batteries every 3-5 years
        - Replace all batteries in UPS (don't mix ages)
        - Use manufacturer-approved batteries
        - Calibrate UPS after battery replacement
        - Document replacement date
        - Dispose of old batteries properly
        
        ### Battery Storage
        - Store batteries in cool, dry place
        - Keep batteries charged (float charge)
        - Don't store batteries for extended periods
        - Check battery voltage monthly if stored
        - Replace stored batteries before installation
        
        ## Power Distribution Best Practices
        
        ### Load Management
        - Calculate total load requirements
        - Maintain load at 80% or less of capacity
        - Distribute load across multiple circuits
        - Use redundant power paths when possible
        - Monitor load continuously
        - Plan for future growth
        
        ### Wiring and Connections
        - Use proper gauge wiring for load
        - Verify all connections are secure
        - Use locking connectors when possible
        - Label all circuits and connections
        - Follow electrical codes and regulations
        - Regular inspection of wiring
        
        ### Redundancy
        - Use A/B power feeds for critical equipment
        - Connect to separate UPS units
        - Use separate electrical circuits
        - Test failover procedures regularly
        - Document power distribution topology
        
        ## Diagnostic Procedures
        
        ### UPS Testing
        - Perform self-test (usually automatic)
        - Manual battery test (simulate outage)
        - Full load test (annual)
        - Runtime test (verify battery capacity)
        - Transfer test (verify switching)
        - Calibration (after battery replacement)
        
        ### Power Quality Monitoring
        - Monitor input voltage and frequency
        - Check for voltage sags and surges
        - Monitor output voltage regulation
        - Check for harmonics and distortion
        - Verify frequency stability
        - Monitor battery charging
        
        ## Required Tools and Equipment
        
        - Multimeter (voltage, current testing)
        - Clamp meter (current measurement)
        - Outlet tester
        - Load bank (testing)
        - Infrared thermometer (temperature)
        - Battery tester
        - Power quality analyzer (advanced)
        
        ## Safety Procedures
        
        ### Electrical Safety
        - Always disconnect power before servicing
        - Verify power is off with multimeter
        - Wear appropriate PPE
        - Follow lockout/tagout procedures
        - Work with qualified electrician for high voltage
        - Be aware of battery hazards (acid, hydrogen gas)
        
        ### Battery Safety
        - Wear safety glasses and gloves
        - Avoid sparks near batteries
        - Ventilate area when working with batteries
        - Don't short battery terminals
        - Dispose of batteries properly
        - Follow manufacturer safety guidelines
        """,
        tags: ["UPS", "Power Distribution", "PDU", "Battery", "Electrical", "Data Center", "Backup Power"],
        lastUpdated: Date(),
        //qrCodeID: "UPS"
    )
}

