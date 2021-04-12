module myconfig

// websites are under $ipaddr/$shortname
// wiki are under $ipaddr/info/$shortname

fn site_config(mut c ConfigRoot) {
	gr_tf1 := TFGroup{
		name: 'tf1'
		members_users: ['kristof', 'adnan', 'rob']
	}
	gr_tf2 := TFGroup{
		name: 'tf2'
		members_users: ['polleke']
		members_groups: ['tf1']
	}

	ace1 := SiteACE{
		groups: ['tf2']
		users: ['polleke2']
		rights: 'R'
		secrets: ['1234', '5678']
	}

	c.sites << SiteConfig{
		name: 'www_threefold_io'
		shortname: 'threefold'
		url: 'https://github.com/threefoldfoundation/www_threefold_io'
		cat: SiteCat.web
		descr: 'is our entry point for everyone, redirect to the detailed websites underneith.'
		domains: ['www.threefold.io', 'www.threefold.me', 'threefold.me', 'new.threefold.io', 'staging.threefold.io',
			'threefold.io',
		]
		groups: [gr_tf1, gr_tf2]
	}
	c.sites << SiteConfig{
		name: 'www_threefold_cloud'
		shortname: 'cloud'
		url: 'https://github.com/threefoldfoundation/www_threefold_cloud'
		cat: SiteCat.web
		domains: ['cloud.threefold.io', 'cloud.threefold.me']
		descr: 'for people looking to deploy solutions on top of a cloud, alternative to e.g. digital ocean'
		acl: [ace1]
	}
	c.sites << SiteConfig{
		name: 'www_threefold_farming'
		shortname: 'farming'
		url: 'https://github.com/threefoldfoundation/www_threefold_farming'
		cat: SiteCat.web
		domains: ['farming.threefold.io', 'farming.threefold.me']
		descr: 'crypto & minining enthusiasts, be the internet, know about farming & tokens.'
	}
	c.sites << SiteConfig{
		name: 'www_threefold_twin'
		shortname: 'twin'
		url: 'https://github.com/threefoldfoundation/www_threefold_twin'
		cat: SiteCat.web
		domains: ['mydigitaltwin.io', 'www.mydigitaltwin.io']
		descr: 'you digital life'
	}
	c.sites << SiteConfig{
		name: 'www_threefold_marketplace'
		shortname: 'marketplace'
		url: 'https://github.com/threefoldfoundation/www_threefold_marketplace'
		cat: SiteCat.web
		domains: ['now.threefold.io', 'marketplace.threefold.io', 'now.threefold.me', 'marketplace.threefold.me']
		descr: 'apps for community builders, runs on top of evdc'
	}
	c.sites << SiteConfig{
		name: 'www_conscious_internet'
		shortname: 'aci'
		url: 'https://github.com/threefoldfoundation/www_conscious_internet'
		cat: SiteCat.web
		domains: ['www.consciousinternet.org', 'eco.threefold.io', 'community.threefold.io', 'eco.threefold.me',
			'community.threefold.me',
		]
		descr: 'community around threefold, partners, friends, ...'
	}
	c.sites << SiteConfig{
		name: 'www_threefold_tech'
		shortname: 'tftech'
		url: 'https://github.com/threefoldtech/www_threefold_tech'
		cat: SiteCat.web
		domains: ['www.threefold.tech', 'threefold.tech']
		descr: 'cyberpandemic, use the tech to build your own solutions with, certification for TFGrid'
	}
	c.sites << SiteConfig{
		name: 'www_examplesite'
		shortname: 'example'
		url: 'https://github.com/threefoldfoundation/www_examplesite'
		cat: SiteCat.web
		domains: ['example.threefold.io']
		descr: ''
	}
	c.sites << SiteConfig{
		name: 'www_uhuru'
		shortname: 'uhuru'
		url: 'https://github.com/uhuru-me/www_uhuru'
		cat: SiteCat.web
		domains: ['www.uhuru.me']
		descr: 'uhuru (freedom) peer2peer cloud.'
	}
	c.sites << SiteConfig{
		name: 'www_mitaa'
		shortname: 'mitaa'
		url: 'https://github.com/mitaa-me/www_mitaa'
		cat: SiteCat.web
		domains: ['www.mitaa.me']
		descr: 'Mitaa website.'
	}
	c.sites << SiteConfig{
		name: 'info_threefold'
		shortname: 'threefold'
		// will be moved to this url
		url: 'https://github.com/threefoldfoundation/info_threefold'
		// url: 'https://github.com/threefoldfoundation/info_foundation_archive'
		domains: ['info.threefold.io', 'wiki.threefold.io']
		descr: 'wiki for foundation, collaborate, what if farmings, tokens'
	}
	// c.sites << SiteConfig{
	// 	name: 'info_marketplace'
	// 	shortname: 'marketplace'
	// 	url: 'https://github.com/threefoldfoundation/info_marketplace'
	// }
	c.sites << SiteConfig{
		name: 'info_uhuru'
		shortname: 'uhuru'
		url: 'https://github.com/uhuru-me/info_uhuru'
		domains: ['info.uhuru.me']
		branch: 's'
		descr: 'wiki for uhuru Peer2Peer Cloud.'
	}
	c.sites << SiteConfig{
		name: 'info_tag'
		shortname: 'tag'
		url: 'https://github.com/takeactionglobal/info_tag'
		domains: ['info.takeactionglobal.org']
		descr: 'wiki for TAG.'
	}
	c.sites << SiteConfig{
		name: 'info_mitaa'
		shortname: 'mitaa'
		url: 'https://github.com/mitaa-me/info_mitaa'
		domains: ['info.mitaa.me', 'info.mitaa.org']
		descr: 'wiki for Mitaa.'
	}
	c.sites << SiteConfig{
		name: 'info_sdk'
		shortname: 'sdk'
		url: 'https://github.com/threefoldfoundation/info_sdk'
		domains: ['sdk.threefold.io']
		descr: 'for IAC, devops, how to do Infrastruture As Code, 3bot, Ansible, tfgrid-sdk, ...'
	}
	c.sites << SiteConfig{
		name: 'info_legal'
		shortname: 'legal'
		url: 'https://github.com/threefoldfoundation/info_legal'
		domains: ['legal.threefold.io', 'legal-info.threefold.io', 'legal-wiki.threefold.io']
		descr: ''
	}
	c.sites << SiteConfig{
		name: 'info_cloud'
		shortname: 'cloud'
		url: 'https://github.com/threefoldfoundation/info_cloud'
		domains: ['cloud-info.threefold.io', 'cloud-wiki.threefold.io']
		descr: 'how to use the cloud for deploying apps: evdc, kubernetes, planetary fs, ... + marketplace solutions '
	}
	c.sites << SiteConfig{
		name: 'info_tftech'
		shortname: 'tftech'
		url: 'https://github.com/threefoldtech/info_tftech'
		domains: ['info.threefold.tech']
		descr: ''
	}
	c.sites << SiteConfig{
		name: 'info_digitaltwin'
		shortname: 'twin'
		url: 'https://github.com/threefoldfoundation/info_digitaltwin.git'
		domains: ['info.mydigitaltwin.io', 'wiki.mydigitaltwin.io']
		descr: ''
	}
	c.sites << SiteConfig{
		name: 'info_bettertoken'
		shortname: 'bt'
		url: 'https://github.com/BetterToken/info_bettertoken.git'
		domains: ['bt-info.threefold.io']
		descr: ''
	}
	c.sites << SiteConfig{
		name: 'data_threefold'
		shortname: 'data'
		url: 'https://github.com/threefoldfoundation/data_threefold'
		cat: SiteCat.data
		domains: []string{}
		descr: ''
	}
}
