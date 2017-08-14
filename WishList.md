## Tasks for completion (GA release)
### Verification steps
* Verify resync functions correctly (YAY)
* Fix connected to (interfaces are not labelling correctly)
* Fix asset tag in spreadsheet to work with leading zeros
* Verify and update documentation.
* Verify and update unit tests.
* Verify default image (because we've been too lazy to wait for it up until now) (YAY)
#### Single access for a site (Dedicate a C3560CG as that device to Gi0/0)
#### Core/Distribution/Access (YAY)
1. 3850-24P = Core (uplink to Gi0/1)
2. 3650-24P = DistA
3. 3850-12S = DistB
4. C3560CG = AccessA to DistA
5. C3560CG = AccessB to DistB
6. C3560CG = AccessC to DistB
#### Distribution/Access (YAY)
1. 3850-24P = Distribution (uplink to Gi0/1)
2. 3650-24P = AccessA
3. 3850-12S = AccessB

### Caveats
* Remove-APICEMNetworkPlugAndPlayProjectDevice does not seem to operate as it should. When using the DeviceID returned by Get-APICEMNetworkPlugAndPlayDevice, APIC-EM claims the device cannot be found
* The script may not properly identify whether a template was actually chosen
* Image (install mode vs. bundle mode). In one mode, the image can't be upgraded. May require further automation
* IOS XE 3.7.1 on Catalyst 4500X crashes on PnP Startup VLAN CDP messages. 4500X devices must not be delivered to site with this image.
* VSS is not supported by APIC-EM
* Spanning tree loops have not been thoroughly tested as of this writing.
* Transitioning from independent mode to port channel has not been tested as of this writing.

## Recommended Wish list items
* Set the tag, command line options (APIs are implemented)
* Add formal logging (take output of deployment and inject into spreadsheet)
* Better verification (break or end script) when non-handled errors occur during claiming and adding to inventory
* Delete finished discovery job following site deployment
* Idempotency (if running the deployment script twice, don't redo what's already done)
* Add deployed configurations to spreadsheet when finished deploying
* Add ISE network device for Radius integration (NAD device for 802.1x)
* Provision discovery DHCP scope as Powershell command
* Implement automated deployment of Palo Alto device and register in Panorama (big job, but worth it)
* Configure interface roles (templates) in spreadsheet deployment plan
* Follow-up verification tool to ensure network is still deployed as designed
* App/Tool to location host or network device by MAC/IP/User/etc...
* Integrate with Serial number to Asset Tag spreadsheet/database to eliminate need to manually enter it
* App/Tool to automate addition tasks related to barcode scanning via mobile devices
* VLAN managment as part of deployment configuration page
* Integrate with IP plan
* Sharepoint integration (our idea, your plan)
* Better Excel spreadsheet design (meaning an actual design as opposed to just "it works"... I.E. Page layout, etc...)
* Possibility for post-installation cleanup job to be triggered on switches (as opposed to KRON timers which may fire incorrectly)
* Add devices, locations, etc... to What's Up Gold and Cisco Prime
* Automate deployment of enterprise certificates as opposed to 'crypto key generate'
* Updated version of network diagram generator that makes Excel shapes instead of PNG (which requires AT&T GraphViz)

## Further communication with Cisco
* Bug report : APIC-EM documentation https://172.16.96.68/api/v1/tag/association/0ad107df-2261-4d30-ba4b-c3a374e6b7e0?resourceType=35f5477c-cec5-49ee-9867-08c91e1f24ee&resourceId=network-device
* Bug report : APIC-EM API - POST /location ignores tag
* Bug report (kinda) : APIC-EM API - Create discovery, protocol order... comma separated? What format... update documentation
* Bug report (kinda) : APIC-EM API - Create discovery, parentDiscoveryId ... how does this work?
* Ask Cisco for APIC-EM API for getting pnp project by device
* Ask Cisco for APIC-EM API for finding discovery jobs
* Bug report/API clarification - Remove PnP Device from PnP Project does not work with PnP Device ID.
