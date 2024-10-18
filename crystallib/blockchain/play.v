module blockchain 

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.texttools


pub fn play_asset(p paramsparser.Params) ! {


    mut digital_assets := get()!

    mut owner := Owner{
        name: p.get('owner')!
    }

    mut account := Account{
        name: texttools.name_fix(p.get('name')!)
        secret: p.get_default('secret','')!
        pubkey: p.get('pubkey')!
        description: p.get_default('description', '')!
        cat: p.get_default('cat', '')!
        owner: owner.name
        bctype: parse_blockchain_type(p.get_default('bctype', 'stellar')!)!
    }

    owner.accounts << account
    digital_assets.owners << owner

}

fn parse_blockchain_type(bctype string) !BlockChainType {
    match bctype {
        'stellar' { return .stellar }
        'stellar_test' { return .stellar_test }
        else { return error('Invalid blockchain type: $bctype') }
    }
}




