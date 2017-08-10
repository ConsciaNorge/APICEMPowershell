# Wishlist Items v1.0
* Get best Cisco IOS image when possible (2 hourish)        (done)
* Create project if project does not already exist (1-2 hours)        (done)
* After device provision, add the device to the inventory as a network device (1-2 hours)        (done)
* When added to the inventory, set the role based on the hostname (30min-1hour)        (done)
* Set the location, command line options (30min+) (APIs implemented... took 2-3 hours)        (done)
* Set the tag, command line options (30min+) (APIs implemented... took 2-3 hours)
* Add verbose messages on compound functions        (in progress, good enough for now)
* Fix possible issue with error that pops up on Wait-APICEMTaskEnded        (done... I hope)
* Make auto-creation of missing resources require -Force        (done)

* Bug report : APIC-EM documentation https://172.16.96.68/api/v1/tag/association/0ad107df-2261-4d30-ba4b-c3a374e6b7e0?resourceType=35f5477c-cec5-49ee-9867-08c91e1f24ee&resourceId=network-device
* Bug report : APIC-EM API - POST /location ignores tag
* Bug report (kinda) : APIC-EM API - Create discovery, protocol order... comma separated? What format... update documentation
* Bug report (kinda) : APIC-EM API - Create discovery, parentDiscoveryId ... how does this work?

* Variables - PNP-Device -> File destination = $StorageSPACE        (done)
* Variables - PNP-Device -> Version string = $versionString        (done)
* Variables - Extract switch role from hostname as $DeviceROLE        (done)
* Variables - Extract project name from hostname as $projectName        (done)

* Fix distribution coming up as core        (done)

FOC1645Y4GC	10.100.5.101 NBN-11111-SA-DEMO101
FOC1646Y0H2	10.100.5.102 NBN-11111-SA-DEMO102
FOC1651Y483	10.100.5.103 NBN-11111-SA-DEMO103
FOC1642Y4LU	10.100.5.104 NBN-11111-SA-DEMO104
FOC1651V0WA	10.100.5.100 NBN-11111-SD-DEMO100

* Increase granularity of timer for display updates on claiming device
* Make progress bar move on claiming device
* Check for claiming errors while waiting for claiming

# Feature request to Cisco
- Make APIC-EM set the repoll timer for a device to 1 minute for up to 10 tries when a device has not yet reached inventory but is in unreachable state. Then revert to system polling timer following that.

# Trond's list of variables of desire
1) image file that is being used (chosen from default image API for platform)
2) serial number 
3) SNMP contact and location (from spreadsheet)


# Add template dropdown to Excel