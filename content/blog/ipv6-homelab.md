---
title: The Shortcomings of IPv6 at Home
date: 2025-02-23
draft: true
toc: true
categories: [networking]
author: Joey Buiteweg
---

# The Problems

IPv6 is wonderful in design. It remediates many blemishes of IPv4. Unfortunately it is avoided in many networks, for both justified and unjustified reasons.

Rather than chastise the world over the unjustified reasons, I’m going to focus on what I think are the main reasons people gravitate away from it, especially in the home lab. This post is about usage in home networks, meaning not in the enterprise.

The simplest reason people don’t use IPv6 at home is because their ISP doesn’t support it. ISPs should support it, but that’s another topic for debate. If your ISP doesn’t support IPv6, then your options to get connectivity to the IPv6 Internet are using a VPN on each device or doing a Tunnel Broker. Both of those options’ IPv6 addresses get denylisted by popular sites, with Netflix being a prime example. A Tunnel Broker requires running a Router that even knows what that is too, which many people do not own.

Assuming your ISP supports IPv6, you’ve turned it on, and want to use it at home, then you run into what I think is an Administrator’s biggest issue with it.

IPv6 was intended to be used with Global Unicast Addresses (GUAs), where every address is globally routable. The IPv4 Internet used to be this way, until we ran out of addresses. Then we had to add NAT, which removed end-to-end connectivity.

**IPv6 with GUAs biggest flaw is that without a stable prefix given to you from your ISP, you do not have stable addresses**. For devices that only connect out to the Internet, this is not a problem. But if you’re hosting services on your network that you want to reach both inside and outside the network, a non-stable address is harder to deal with.

# Terminology

* Private IPv4 Address: An address from the RFC1918 block, one of 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16, that is not globally routable. Analogous to IPv6 ULAs but have differences that aren’t important to this post. To keep terminology proper I will use Private IPv4 and IPv6 ULA separately.
	* Example: 10.22.0.1
* Public IPv4 address: An IPv4 address that is publicly routable on the internet. This is analogous to an IPv6 Global Unicast Address. To keep terminology proper I will use Public IPv4 and IPv6 GUA separately.
	* Example: 1.1.1.1 (Cloudflare’s Public DNS Resolver)
* IPv6 ULA: Unique Local Address. Non publicly-routable addresses. They come from the block fc00::/7, and are an unfortunate bandaid used on IPv6 networks.
	* Example: fce2:89:89:89::8
* IPv6 GUA: Global Unicast Address. Publicly routable
	* Example: 2606:4700:4700::1111 (Cloudflare’s Public DNS Resolver)
* SLAAC: Stateless Local Auto Address Configuration. A way for IPv6 devices to get addresses without the Router needing to keep state. They pick their addresses based on Prefix + MAC address.

# Stable Addresses

Here’s an example to show why we care about stable addresses.

Let’s say you want to run your own forwarding DNS Resolver that does Ad blocking. Pi-hole, Ad guard home, Technitium, are all examples.

In order to have your devices leverage this Ad blocking, they need to send their DNS queries to this Resolver. To do so, they need the Resolver’s IP Address.

An IPv4 LAN at home will almost always have a set of Private Addresses, which are NAT’d to a single Public IPv4 Address for the WAN. 1.1.1.1 is an example of a Public IPv4. At home, you get a single Public IP, offered via DHCP, for your WAN connection from your ISP, which is subject to change.

The IPv4 LAN Private IPs will not change even if your WAN’s Public IP changes. That is, if your GUA goes from 123.123.123.123 to 123.123.123.124 (assume those are globally routable), your addresses such as 10.88.0.1, 10.88.0.2, do not need to change.

This makes it simple to choose an address for that Ad-blocking DNS Resolver. You can choose 10.88.0.2 for example, and it can stay that way until *you* decide to change it. Now your DHCP server can send that address as the LAN’s DNS Resolver and you’re good to go. Whether you assign 10.88.0.2 as a Static Address or a DHCP reservation is irrelevant here, what matters is that that address does not need to change.

# IPv6 At Home

IPv6 for homes whose ISPs provide it looks like this.

Instead of a single Public IP offered via DHCP, you get an entire IPv6 Prefix delegated to your Network. This is called your Prefix Delegation (PD) and it’s given to your Router via DHCPv6.

For example, your home has a Router. It asks the ISP’s Router for an IPv6 Prefix via DHCPv6, it gets back 2001:db8:beef::/56 . You can now divvy up your devices’ addresses from that Prefix. This should be done via SLAAC, which removes the need for the Router to keep track of which address which device is using, as is the case for DHCP. DHCPv6 on the LAN is an option, but should be avoided unless needed since SLAAC can do the same job with less broadcast traffic. Devices send Router Solicitations and Routers send Router Advertisements, similar to DHCP request and response.

Continuing the example, if we got a /56 from the ISP, we should split it up into /64s. The smallest prefix/subnet an IPv6 network should operate at is a /64. That’s per the standard. That is more addresses than most subnets will need, but it doesn’t matter because there are more than enough /64s to go around. SLAAC is meant to be used with a /64, but I’ve heard of it being used with /32s in the Data Center context. One /56 can be turned into 256 /64s, which we can use for different VLANs. I’ll cover this idea and VLANs in another blog post.

Notice how much IPv6 addresses rely upon the Prefix Delegation?
This Prefix Delegation *is subject to change*. Herein lies the problem.

Let’s go back to that Ad-blocking DNS Resolver example.

Let’s say we got 2001:dead:beef::/56 in our Prefix Delegation from the ISP. We could then pick 2001:dead:beef:1::/64 as our LAN prefix. (Other VLANs could be 2001:dead:beef:2::/64, 2001:dead:beef:3::/64, and so on).

Let’s say our device that will run the Resolver has MAC address 32:33:34:35:36:37. Using the EUI64 algorithm that is a part of SLAAC, it will then assign its own address based on the /64 for the LAN and the MAC. In this instance it will pick 2001:dead:beef:1:3033:34ff:fe35:3637 as its address using the [EUI64 algorithm](https://eui64-calculator.nickfedor.com/) that is a part of SLAAC.

SLAAC has an extension, called RDNSS, that lets a Router advertise multiple DNS resolvers to devices on the network when sending Router Advertisements, just like how DHCP does.

We would then have our Router advertise 2001:dead:beef:1:3033:34ff:fe35:3637 as one of the DNS resolvers for this LAN.

But what if our Router restarts, loses its DHCPv6 lease from the ISP’s router, and then gets assigned 2001:dead:dead::/56 in its Prefix Delegation? The previous IP we configured in RDNSS is now no longer valid!

Aside from SLAAC we can also assign that device a static IP from the LAN’s /64. There are no rules against this in IPv6. IPv6 even has extensions for dedicating duplicate addresses to ensure there are no conflicting IPs operating on the network. But even with Static IPs in this scenario, if the Prefix Delegation changes, the old Static IPs are no longer valid!

Now after all this headache of setting up IPv6, which people aren’t motivated to do in the first place, we are left with a worse setup than IPv4 with respect to stable local addresses.

However there are ways to fight this shortcoming, some more cumbersome than others.

# The Options

## Business Plan at Home

A business plan at home is considerably more expensive, but does usually guarantee static IP assignments from your ISP, for both IPv6 and IPv4!

Yes, on residential plans your Public IPv4 address is subject to change too. One unstable address for IPv4 is easier to manage than many unstable addresses from IPv6 though.

A business plan is a valid strategy to get around this problem. It removes the need for any Dynamic DNS usage (DDNS) too, as is common in both IPv4 and IPv6 deployments at home.

## Use IPv6 ULAs alongside GUAs

You can assign multiple IP addresses from different prefixes to an interface in IPv6.

In this scenario we would have our prefix 2001:dead:beef:1::/64 assigned to the LAN, which is subject to change, and we would assign an additional prefix from the fc00::/7 block designated for ULAS, like fce2:10:88:0::/64.

You’re supposed to pick ULAS far more randomly than the scheme in this example as per [the RFC](https://datatracker.ietf.org/doc/html/rfc4193#section-3.2)

> The allocation of Global IDs is pseudo-random [RANDOM].  They MUST NOT be assigned sequentially or with well-known numbers. This is to ensure that there is not any relationship between allocations and to help clarify that these prefixes are not intended to be routed globally.  Specifically, these prefixes are not designed to aggregate.

But there is no Internet police enforcing this. On your home network a few ULAs that have a predictable addressing scheme will not hurt anyone. If I end up being jailed by the IETF, you’ll know why lol.

Back to the example, the LAN has 2001:dead:beef:1::/64 and fce2:10:88:0::/64 assigned.

Now the Ad-blocking Resolver will get two IPv6 addresses on this LAN, both calculated using the EUI-64 algorithm discussed earlier. Again its MAC address is 32:33:34:35:36:37. These addresses will be 2001:dead:beef:1:3033:34ff:fe35:3637 and fce2:10:88:0:3033:34FF:FE35:3637

Now the Router can use the fce2 address in its RDNSS advertisements without fear of it changing.

To quote a colleague of mine who is a volunteer for ARIN, “I view any time that someone considers IPv6 ULAs a ‘good thing’ as a failure.” Which I agree with. Setting them up is cumbersome.

# IPv6 NAT ULAs to GUAs

Here’s where things get even more spicy.

You would think you could NAT IPv6 ULAs into GUAs using prefix translation, (NPTv6 is the common one), but doing that is actually pointless for dual-stack networks. Dual-stack means you have IPv4 and IPv6 set up, which is the most common way to deploy IPv6 today. More on dual-stack networks at the end.

When it comes to choosing what source address to use for a connection, applications use something called the “happy eyeballs” algorithm. If a host has both an IPv4 and an IPv6 A/AAAA DNS record then you race connecting to both and see which one comes back faster.

[This article](https://blog.ipspace.net/2022/05/ipv6-ula-made-useless/) linked from [this forum post](https://forum.opnsense.org/index.php?topic=33902.0) indicate that IPv6 ULAs have a lower priority than IPv4 when it comes to picking an address in the happy eyeballs algorithm.

In this case if your network devices don’t know about the GUAs, and instead solely see a Private IPv4 and an IPv6 ULA on their interface, they will always pick the Private IPv4 when accessing the internet.

For example, if the Resolver from before had fce2:10:88:0:3033:34FF:FE35:3637 and 10.88.0.2 assigned to its network port, it won’t ever use the fce2 address.

Contrast this to example before where the Resolver would have 2001:dead:beef:1:3033:34ff:fe35:3637, fce2:10:88:0:3033:34FF:FE35:3637, and 10.88.02. In this example it will race between the 2001: and 10.88 addresses.

# IPv6 NAT GUA to GUA

A hack mentioned in [the forum post](https://forum.opnsense.org/index.php?topic=33902.0)) from before is to rent an IPv6 allocation from ARIN and then use a portion of it on your LAN instead of the ULAs.

Let’s say we rented a /56 from ARIN, in reality you get much larger allocation but for this example that’s irrelevant. The /56 they gave us was 2001:db8:1234::/56 .

In this scenario we would ensure that this not prefix is advertised over a BGP session to another router anywhere on the internet.

Let’s say we got the same PD from our ISP before, 2001:dead:beef::/56 .

We would then configure our router to NAT the whole ARIN prefix 2001:db8:1234::/56 to the ISP prefix 2001:dead:beef::/56.

Now all that Resolver would see is 

2001:db8:1234:1:3033:34ff:fe35:3637 and 10.88.0.2

And be none the wiser to the NAT that is going on. And because we are renting that prefix from ARIN, it will never change, unless we stop paying them!

This scenario is doable but is expensive.

In the US a lease from ARIN is at minimum $275 [a year](https://www.arin.net/resources/fees/fee_schedule/).

My Google Fiber residential 1G plan is $70 a month. A business 1G plan is $100. I don’t know if the 1G plan comes with static IPs or not. The business 2G plan is $250 a month. An ARIN allocation is more expensive than all of those! Getting a Business Plan likely requires registering a business at your home address, which I would have to research how to do.

The solution to this cost is to have more friends who have ARIN allocations who are willing to give you a portion theirs lol.

# DHCPv6 Tricks

For Opnsense, which is my home router for now, I’ve seen [tips](https://www.reddit.com/r/googlefiber/comments/1k4h3q1/comment/moasgs5/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button) that you can get a stable prefix by doing

Interfaces->Settings->IPv6 DHCP, check Prevent Release

This setting makes Opnsense not send a DHCPv6 release message when it gets restarted.

They state that your MAC address and DHCP Unique Identifier (DUID) should also not change if you want to keep the same Prefix.

Opnsense should keep the same DUID from boot to boot.

If you move to a new device you can always change its MAC address if supported. Otherwise if you virtualize Opnsense (run in a VM) then your MAC address will stay the same when moving a VM from one hypervisor to another, that is unless you change the MAC yourself manually. If I’m wrong about this or anything else in the blog post please let me know by opening a Github discussion on this article.

I’ve enabled “Prevent Release” and did “Insert existing DUID” in the settings in Opnsense. I will have to see how stable my prefix is over time. My plan is to track that continuously with Prometheus and graph it with Grafana. 

I’m currently using the “Use IPv6 ULAs alongside GUAs” approach from above.

If my prefix stays stable after these tricks then I will remove the ULAs from the setup.

But even needing to worry about this at all is a huge shortcoming of IPv6 at home.

That’s it! Let me know what you think of this article via my contact info or Github discussion this markdown file. Thanks for reading!