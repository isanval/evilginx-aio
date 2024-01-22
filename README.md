# Evilginx3 All-In-One script

This script is intended to use in [Kali Linux](https://www.kali.org) (rolling version), it will install [Evilginx3](https://github.com/kgretzky/evilginx2) with these public phishlets repositories automatically:
- [BakkerJan](https://github.com/BakkerJan/evilginx2.git)
- [An0nUD4Y](https://github.com/An0nUD4Y/Evilginx2-Phishlets.git)

The script will set up two phishing sites:
- MS365
- Github

# Quick run

**Create 2 DNS entries** pointing the public IP address from the server:

    ns-<mysubdomain>.myown.tools.   A     <PUBLIC_IP_ADDRESS>
    <mysubdomain>.myown.tools.      NS    ns-<mysubdomain>.myown.tools.

Be sure that **ports UDP/53 and TCP/443 are accessible through the <PUBLIC_IP_ADDRESS>** in Kali Linux and run:

    domain="mysubdomain.myown.tools" bash <(wget -q -O- "https://raw.githubusercontent.com/isanval/evilginx-aio/main/evilginx-aio.sh")

**BE PATIENT DURING THE FIRST RUN AS IT WILL NEED TO UPGRADE THE FULL OS**

This is a sample output for the first run until Evilginx3 starts:

[PENDING INSERT IMAGE]

Once Evilginx3 is started and ready, you can check the phishing URLs with these commands:

    lures
    lures get-url <id>

[PENDING INSERT IMAGE]

After that, you can access the two phishing URLs you got from `lures get-url <id>` commands.

In case you need your own sauce, you can check the [Evilginx3 official documentation](https://help.evilginx.com/).

# Requirements

There are really few requirements to have the phishing sites up and running:
- Kali Linux OS up and running
- Standard user with SUDO/root privileges
- Public IP address (or NAT configured)
- Public accessible TCP/UDP
- DNS domain or subdomain available
- [evilginx-aio.sh](https://github.com/isanval/evilginx-aio/blob/main/evilginx-aio.sh) script

## Kali Linux 

https://www.kali.org/get-kali/#kali-platforms

No needed description here, just install in your preferred lab/cloud a fresh Kali Linux :-)

## Standard user with SUDO/root privileges

In case you don't know what I'm talking about, [here](https://www.kali.org/docs/general-use/sudo/) you can check the details.

## Public IP

[Evilginx3](https://github.com/kgretzky/evilginx2) will run its own DNS/HTTPS servers and it will request valid SSL/TLS certificates through [Let's Encrypt](https://letsencrypt.org/) service so the Kali Linux server will need Internet access and also a public IP address (or a NATed one).

## Public accessible TCP/UDP ports

Evilginx3 will run its own DNS and HTTPS servers so at least we need these ports publicly accessible from Internet:
  - Port 53 UDP
  - Port 443 TCP

You can rename the current file by clicking the file name in the navigation bar or by clicking the **Rename** button in the file explorer.

## DNS domain/subdomain

Evilginx will use its own subdomain for all phishing simulation attacks. So you will need your own domain and set up a subdomain with its own NS entry pointing to public IP from Kali Linux.

For example, in [BIND9](https://www.isc.org/bind/) you can create this two entries in your domain zone configuration:

    ns-<mysubdomain>.myown.tools.   A     <PUBLIC_IP_ADDRESS>
    <mysubdomain>.myown.tools.      NS    ns-<mysubdomain>.myown.tools.
