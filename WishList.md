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

* Fix distribution coming up as core