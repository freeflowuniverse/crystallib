module myconfig

fn site_config(mut c ConfigRoot) {
	c.sites << SiteConfig{
		name: 'www_threefold_io'
		shortname: 'tf'
		url: 'https://github.com/threefoldfoundation/www_threefold_io'
		cat: SiteCat.web
		descr: 'is our entry point for everyone, redirect to the detailed websites underneith.'
		domains: {'new.threefold.io': 'staging'}
		standalone: true
	}
	c.sites << SiteConfig{
		name: 'www_threefold_cloud'
		shortname: 'cloud'
		url: 'https://github.com/threefoldfoundation/www_threefold_cloud'
		cat: SiteCat.web
		domains: {'new.threefold.io': 'staging'}
		descr: 'for people looking to deploy solutions on top of a cloud, alternative to e.g. digital ocean'
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'www_threefold_farming'
		shortname: 'farming'
		url: 'https://github.com/threefoldfoundation/www_threefold_farming'
		cat: SiteCat.web
		domains: {'new.threefold.io': 'staging'}
		descr: 'crypto & minining enthusiasts, be the internet, know about farming & tokens.'
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'www_threefold_twin'
		shortname: 'twin'
		url: 'https://github.com/threefoldfoundation/www_threefold_twin'
		cat: SiteCat.web
		domains: {'new.threefold.io': 'staging'}
		descr: "you digital life"
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'www_threefold_marketplace'
		shortname: 'marketplace'
		url: 'https://github.com/threefoldfoundation/www_threefold_marketplace'
		cat: SiteCat.web
		domains: {'new.threefold.io': 'staging'}
		descr: "apps for community builders, runs on top of evdc"
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'www_conscious_internet'
		shortname: 'conscious_internet'
		url: 'https://github.com/threefoldfoundation/www_conscious_internet'
		cat: SiteCat.web
		domains: {'new.threefold.io': 'staging'}
		descr: 'community around threefold, partners, friends, ...'
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'www_threefold_tech'
		shortname: 'tech'
		url: 'https://github.com/threefoldtech/www_threefold_tech'
		cat: SiteCat.web
		domains: {'new.threefold.io': 'staging'}
		descr: 'cyberpandemic, use the tech to build your own solutions with, certification for TFGrid'
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'www_examplesite'
		shortname: 'example'
		url: 'https://github.com/threefoldfoundation/www_examplesite'
		cat: SiteCat.web
		domains: {'new.threefold.io': 'staging'}
		descr :''
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'info_threefold'
		shortname: 'threefold'
		//will be moved to this url
		// url: 'https://github.com/threefoldfoundation/info_threefold'
		url: 'https://github.com/threefoldfoundation/info_foundation_archive'
		domains: {'new.threefold.io': 'staging'}
		descr :'wiki for foundation, collaborate, what if farmings, tokens'
		standalone: false
	}
	// c.sites << SiteConfig{
	// 	name: 'info_marketplace'
	// 	shortname: 'marketplace'
	// 	url: 'https://github.com/threefoldfoundation/info_marketplace'
	// }
	c.sites << SiteConfig{
		name: 'info_sdk'
		shortname: 'sdk'
		url: 'https://github.com/threefoldfoundation/info_sdk'
		domains: {'new.threefold.io': 'staging'}
		descr: 'for IAC, devops, how to do Infrastruture As Code, 3bot, Ansible, tfgrid-sdk, ...'
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'info_legal'
		shortname: 'legal'
		url: 'https://github.com/threefoldfoundation/info_legal'
		domains: {'new.threefold.io': 'staging'}
		descr :''
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'info_cloud'
		shortname: 'cloud'
		url: 'https://github.com/threefoldfoundation/info_cloud'
		domains: {'new.threefold.io': 'staging'}
		descr :'how to use the cloud for deploying apps: evdc, kubernetes, planetary fs, ... + marketplace solutions '
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'info_tftech'
		shortname: 'tftech'
		url: 'https://github.com/threefoldtech/info_tftech'
		domains: {'new.threefold.io': 'staging'}
		descr :''
		standalone: false
	}
	c.sites << SiteConfig{
		name: 'info_digitaltwin'
		shortname: 'twin'
		url: 'https://github.com/threefoldfoundation/info_digitaltwin.git'
		domains: {'new.threefold.io': 'staging'}
		descr :''
		standalone: false
	}

	c.sites << SiteConfig{
		name: 'info_bettertoken'
		shortname: 'bt'
		url: 'https://github.com/BetterToken/info_bettertoken.git'
		domains: {'new.threefold.io': 'staging'}
		descr :''
		standalone: false
	}

	
	c.sites << SiteConfig{
		name: 'data_threefold'
		shortname: 'data'
		url: 'https://github.com/threefoldfoundation/data_threefold'
		cat: SiteCat.data
		domains: map[string]string{}
		standalone: false
		descr :''
	}
}
