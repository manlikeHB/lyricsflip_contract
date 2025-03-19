use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Card {
    #[key]
    pub card_id: u256,
    pub genre: felt252,
    pub artist: felt252, // TODO: review datatype in order to use ByteArray as key in map
    pub title: felt252,
    pub year: u64,
    pub lyrics: felt252,
}
